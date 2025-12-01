#!/usr/bin/python3
import copy
import os
import sys
import yaml
import argparse
import subprocess
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, PlatformFlavor
from components.CiConfigurationUtils import *


# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to run builds for multiple projects and their dependencies on CI')
parser.add_argument('-p','--projects', nargs='+', help='Dirty projects that has been changed', required=True)
parser.add_argument('--branch', type=str, required=True)
parser.add_argument('--platform', type=str, required=True)
parser.add_argument('--skip-dependencies-fetch', default=False, action='store_true')
parser.add_argument('--publish-to-cache', default=False, action='store_true')
parser.add_argument('--missing-only', default=False, action='store_true')
parser.add_argument('-n', '--dry-run', default=False, action='store_true')

arguments = parser.parse_args()

platform = PlatformFlavor.PlatformFlavor(arguments.platform)

if len(arguments.projects) == 1 and ' ' in arguments.projects[0]:
    fixedProjects = arguments.projects[0].split();
    print("Fixing the projects list: {} -> {}", arguments.projects, fixedProjects)
    arguments.projects = fixedProjects

# This is a giant speedup on @same dependency lookup, especially on Windows
if not 'CI_MERGE_REQUEST_TARGET_BRANCH_NAME' in os.environ:
    os.environ['CI_MERGE_REQUEST_TARGET_BRANCH_NAME'] = arguments.branch

workingDirectory = os.getcwd()
seedFile = os.path.join(workingDirectory, 'latest', 'krita-deps.yml')

dependencyResolver = prepareDependenciesResolver(platform)

allSeededDeps = []
with open(seedFile, 'r') as f:
    allSeededDeps = yaml.safe_load(f)

platformDeps = []

for rule in allSeededDeps:
    if platform.matches(rule['on']):
        for dep in rule['require'].keys():
            projectId = dependencyResolver.projects[dep]['identifier']
            platformDeps.append(projectId)

print("## plaform: {}".format(platform))
print("## plaform deps: {}".format(platformDeps))

reverseDeps = {}

print ('##')
print ('## Start building dependencies tree...')
print ('##')

reverseDeps = genReverseDeps(workingDirectory,
                             dependencyResolver,
                             arguments.branch,
                             debug = True,
                             onlyPlatformDeps = platformDeps)

print ('##')
print ('## Reverse dependency tree:')
print ('##')

for projectName, dependants in reverseDeps.items():
    print ("##  project: {} dependants: {}".format(projectName, dependants))
print ('##')
print ('##')

def searchForCyclicDependencies(currentChain, reverseDeps):
    if not currentChain[-1] in reverseDeps:
        return []

    dependants = reverseDeps[currentChain[-1]]
    for dep in dependants:
        chain = copy.copy(currentChain)
        chain.append(dep)

        if dep in currentChain:
            return chain

        foundChain = searchForCyclicDependencies(chain, reverseDeps)
        if foundChain:
            return foundChain

    return []

for project in reverseDeps.keys():
    foundChain = searchForCyclicDependencies([project], reverseDeps)
    if foundChain:
        print('ERROR: found a cyclic dependency: {}'.format(' <- '.join(foundChain)))
        sys.exit(1)

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

if arguments.skip_dependencies_fetch:
    commandToRun += " --skip-dependencies-fetch"

if arguments.publish_to_cache:
     commandToRun += ' --publish-to-cache'

if arguments.missing_only:
     commandToRun += ' --missing-only'


print('## Run the build for the requested projects: {}'.format(commandToRun))

if not arguments.dry_run:
    # Then run it!
    subprocess.check_call( commandToRun, stdout=sys.stdout, stderr=sys.stderr, shell=True, cwd=workingDirectory )
else:
    print('## skipping due to --dry-run option present...')
