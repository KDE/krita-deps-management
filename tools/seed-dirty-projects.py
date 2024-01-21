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

dependencyResolver = prepareDependenciesResolver(platform)
reverseDeps = {}

print ('##')
print ('## Start building dependencies tree...')
print ('##')

reverseDeps = genReverseDeps(workingDirectory, dependencyResolver, arguments.branch, debug = True)

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

if arguments.skip_dependencies_fetch:
    commandToRun += " --skip-dependencies-fetch"

print('## Run the build for the requested projects: {}'.format(commandToRun))

# Then run it!
subprocess.check_call( commandToRun, stdout=sys.stdout, stderr=sys.stderr, shell=True, cwd=workingDirectory )
