#!/usr/bin/python3
import copy
import os
import sys
import yaml
import argparse
import subprocess
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, Dependencies, PlatformFlavor

####
# Load the project configuration
####
def loadProjectConfiguration(projectRoot, projectName):
    # This consists of:
    # 0) Global configuration
    configuration = yaml.safe_load( open(os.path.join(CommonUtils.scriptsBaseDirectory(), 'config', 'global.yml')) )

    # 1) Project/branch specific configuration contained within the repository
    if os.path.exists(os.path.join(projectRoot, '.kde-ci.yml')):
        localConfig = yaml.safe_load( open(os.path.join(projectRoot, '.kde-ci.yml')) )
        CommonUtils.recursiveUpdate( configuration, localConfig )

    # 2) Global overrides applied to the project configuration
    projectConfigFile = os.path.join(CommonUtils.scriptsBaseDirectory(), 'config', projectName + '.yml')
    if os.path.exists( projectConfigFile ):
        projectConfig = yaml.safe_load( open(projectConfigFile) )
        CommonUtils.recursiveUpdate( configuration, projectConfig )

    if 'KDECI_GLOBAL_CONFIG_OVERRIDE_PATH' in os.environ:
        overridePath = os.environ['KDECI_GLOBAL_CONFIG_OVERRIDE_PATH']
        if os.path.exists( overridePath ):
            overrideConfig = yaml.safe_load( open(overridePath) )
            CommonUtils.recursiveUpdate( configuration, overrideConfig )
        else:
            print('## Error: $KDECI_GLOBAL_CONFIG_OVERRIDE_PATH({}) is present, but the file doesn\'t exist'.format(overridePath))
            sys.exit(-1)

    return configuration

####
# Prepare to resolve and fetch our project dependencies
####
def prepareDependenciesResolver(platform):
    metadataFolderPath = os.environ.get('KDECI_REPO_METADATA_PATH', os.path.join(CommonUtils.scriptsBaseDirectory(), 'repo-metadata'))

    # Determine where some key resources we need for resolving dependencies will be found...
    projectsMetadataPath = os.path.join( metadataFolderPath, 'projects-invent' )
    branchRulesPath = os.path.join( metadataFolderPath, 'branch-rules.yml' )

    # Bring our dependency resolver online...
    return Dependencies.Resolver( projectsMetadataPath, branchRulesPath, platform )



# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to run builds for multiple projects and their dependencies on CI')
parser.add_argument('-p','--projects', nargs='+', help='Dirty projects that has been changed', required=True)
parser.add_argument('--branch', type=str, required=True)
parser.add_argument('--platform', type=str, required=True)
arguments = parser.parse_args()

platform = PlatformFlavor.PlatformFlavor(arguments.platform)

if len(arguments.projects) == 1 and ' ' in arguments.projects[0]:
    fixedProjects = arguments.projects[0].split();
    print("Fixing the projects list: {} -> {}", arguments.projects, fixedProjects)
    arguments.projects = fixedProjects

workingDirectory = os.getcwd()

dependencyResolver = prepareDependenciesResolver(platform)
reverseDeps = {}

print ('##')
print ('## Start building dependencies tree...')
print ('##')

for subdir, dirs, files in os.walk(workingDirectory):
    relative = os.path.relpath(subdir, workingDirectory)
    depth = os.path.normpath(relative).count(os.sep) + 1

    if depth >= 2:
        dirs.clear()

    subDirName = os.path.basename(subdir)

    if subDirName == os.path.basename(workingDirectory):
        continue

    if not subDirName.startswith('ext_'):
        dirs.clear()
        continue

    projectName = subDirName

    if os.path.exists(os.path.join(subdir, 'CMakeLists.txt')):
        configuration = loadProjectConfiguration(subdir, projectName)
        projectBuildDependencies = dependencyResolver.resolve( configuration['Dependencies'], arguments.branch )
        print ("##  project: {} depends: {}".format(projectName, list(projectBuildDependencies.keys())))

        # found the project, don't check subdirs anymore
        dirs.clear()

        for dep, _branch_unused in projectBuildDependencies.items():
            if dep in reverseDeps:
                reverseDeps[dep].add(projectName)
            else:
                reverseDeps[dep] = set([projectName])

print ('##')
print ('## Reverse dependency tree:')
print ('##')

for projectName, dependants in reverseDeps.items():
    print ("##  project: {} dependants: {}".format(projectName, dependants))
print ('##')
print ('##')

projectsToRebuild = set()
dirtyProjects = set()

print ('##')
print ('## Dirty projects:')

for projectName in arguments.projects:
    projectId = dependencyResolver.projects[projectName]['identifier']
    dirtyProjects.add(projectId)
    print ("##  {} ({})".format(projectName, projectId))

print ('##')

while dirtyProjects:
    projectsToProcess = copy.copy(dirtyProjects)
    dirtyProjects.clear()
    for project in projectsToProcess:
        if not project in projectsToRebuild:
            projectsToRebuild.add(project)
            if project in reverseDeps:
                dirtyProjects.update(reverseDeps[project])

print ('##')
print ('## Projects to rebuild:')

projectNamesToRebuild = []
for projectId in projectsToRebuild:
    projectName = dependencyResolver.projectsByIdentifier[projectId]['repopath']
    projectNamesToRebuild.append(projectName)
    print ("##  {} ({})".format(projectName, projectId))
print ('##')

commandToRun = "{0} -u {1}/seed-multiple-projects.py -p {2} --platform {3} --branch {4}".format(
            sys.executable,
            CommonUtils.scriptsBaseDirectory(),
            ' '.join(projectNamesToRebuild),
            arguments.platform,
            arguments.branch
        )

print('## Run the build for the requested projects: {}'.format(commandToRun))

# Then run it!
subprocess.check_call( commandToRun, stdout=sys.stdout, stderr=sys.stderr, shell=True, cwd=workingDirectory )
