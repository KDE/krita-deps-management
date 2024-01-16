#!/usr/bin/python3
import copy
import os
import sys
import yaml
import argparse
import subprocess
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, Dependencies, PlatformFlavor

#
# TODO: 
# 1) Implement option for the seed file
# 2) Implement ignore arg to skip some deps (e.g. qt and patch)
# 3) Deduplicate
#

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
#parser.add_argument('-p','--projects', nargs='+', help='Dirty projects that has been changed', required=True)
parser.add_argument('--branch', type=str, required=True)
parser.add_argument('--platform', type=str, required=True)
parser.add_argument('--skip-dependencies-fetch', default=False, action='store_true')
arguments = parser.parse_args()

# if len(arguments.projects) == 1 and ' ' in arguments.projects[0]:
#     fixedProjects = arguments.projects[0].split();
#     print("Fixing the projects list: {} -> {}", arguments.projects, fixedProjects)
#     arguments.projects = fixedProjects

# This is a giant speedup on @same dependency lookup, especially on Windows
if not 'CI_MERGE_REQUEST_TARGET_BRANCH_NAME' in os.environ:
    os.environ['CI_MERGE_REQUEST_TARGET_BRANCH_NAME'] = arguments.branch

workingDirectory = os.getcwd()




print ('##')
print ('## Start building dependencies tree...')
print ('##')

def genReverseDeps(workingDirectory, dependencyResolver):
    reverseDeps = {}
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
    return reverseDeps

linuxPlatform = PlatformFlavor.PlatformFlavor('Linux')
linuxDependencyResolver = prepareDependenciesResolver(linuxPlatform)
linuxReverseDeps = genReverseDeps(workingDirectory, linuxDependencyResolver)

windowsPlatform = PlatformFlavor.PlatformFlavor('Windows')
windowsDependencyResolver = prepareDependenciesResolver(windowsPlatform)
windowsReverseDeps = genReverseDeps(workingDirectory, windowsDependencyResolver)

import graphviz

dot = graphviz.Digraph(comment='Krita Dependencies', engine = 'neato', graph_attr= {'root':'ext_qt', 'overlap':'false', 'splines':'true'})

# color coding:
# red - Linux only
# blue - Windows only
# black - both

knownNodes = {}
knownEdges = {}

seedFile = os.path.join(os.path.dirname(__file__), '..', 'latest', 'krita-deps.yml')

dependencies = []
with open(seedFile, 'r') as f:
    dependencies = yaml.safe_load(f)

print ('len: {}'.format(len(dependencies)))
print (dependencies)

for rule in dependencies:
    if '@all' in rule['on']:
        for dep in rule['require'].keys():
            projectId = linuxDependencyResolver.projects[dep]['identifier']
            knownNodes[projectId] = 'black'
    if 'Linux' in rule['on']:
        for dep in rule['require'].keys():
            projectId = linuxDependencyResolver.projects[dep]['identifier']
            if projectId in knownNodes:
                knownNodes[projectId] = 'black'
            else:
                knownNodes[projectId] = 'magenta'
    if 'Windows' in rule['on']:
        for dep in rule['require'].keys():
            projectId = linuxDependencyResolver.projects[dep]['identifier']
            if projectId in knownNodes:
                knownNodes[projectId] = 'black'
            else:
                knownNodes[projectId] = 'blue'

def addLinuxNode(projectName):
    if not projectName in knownNodes:
        knownNodes[projectName] = 'red'

def addWindowsNode(projectName):
    if not projectName in knownNodes:
        knownNodes[projectName] = 'red'

for projectName, dependants in linuxReverseDeps.items():
    addLinuxNode(projectName)
    
    for dep in dependants:
        addLinuxNode(dep)
        knownEdges[(projectName, dep)] = 'magenta'

for projectName, dependants in windowsReverseDeps.items():
    addWindowsNode(projectName)
    for dep in dependants:
        addWindowsNode(dep)

        color = 'blue'

        if (projectName, dep) in knownEdges:
            color = 'black'
        
        knownEdges[(projectName, dep)] = color

for projectName, color in knownNodes.items():
    dot.node(projectName, color = color)

for (projectName, dep), color in knownEdges.items():
    print ('{} -> {}: {}'.format(projectName, dep, color))
    dot.edge(projectName, dep, color = color)

print(dot.source)

dot.format = 'png'
dot.render(directory='doctest-output').replace('\\', '/')
