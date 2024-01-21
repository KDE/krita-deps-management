#!/usr/bin/python3
import copy
import os
import sys
import yaml
import argparse
import subprocess
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, Dependencies, PlatformFlavor
import graphviz

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
parser.add_argument('--branch', type=str, required=True)
parser.add_argument('--seed-file', type=str, required=True)
parser.add_argument('-s','--skip-deps', nargs='+', help='A space-separated list of dependencies to skip from the graph (\'ext_foo\' format); when combined with --only-deps removes deps from the --only-deps subset', required=False)
parser.add_argument('-d','--only-deps', nargs='+', help='A space-separated list of dependencies to include into the graph, all other deps are ignored (\'ext_foo\' format)', required=False)
parser.add_argument('-o','--output', type=str, help='Name of the output file', required=False, default='dependencies.png')
arguments = parser.parse_args()

if not arguments.skip_deps is None and \
    not arguments.only_deps is None:

    skipSet = set(arguments.skip_deps)
    onlySet = set(arguments.only_deps)
    intersection = skipSet & onlySet

    if intersection:
        print ('ERROR: --skip-deps and --only-deps sets of dependencies intersect: {}'.format(intersection))
        sys.exit(1)

# This is a giant speedup on @same dependency lookup, especially on Windows
if not 'CI_MERGE_REQUEST_TARGET_BRANCH_NAME' in os.environ:
    os.environ['CI_MERGE_REQUEST_TARGET_BRANCH_NAME'] = arguments.branch

workingDirectory = os.getcwd()

def genReverseDeps(workingDirectory, dependencyResolver, debug = False):
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

            if debug:
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

onlyLegengLine = ''
skipLegendLine = ''

if not arguments.only_deps is None:
    onlyLegengLine = '<tr><td colspan=\"3\">Only: {}</td></tr>'.format(', '.join(arguments.only_deps))
if not arguments.skip_deps is None:
    skipLegendLine = '<tr><td colspan=\"3\">Skip: {}</td></tr>'.format(', '.join(arguments.skip_deps))

dot = graphviz.Digraph(comment='Krita Dependencies', engine = 'neato')
dot.attr(overlap='false')
dot.attr(splines='true')
dot.attr(root='ext_qt')
dot.attr(pack='true')
dot.attr(packMode='clust')
dot.attr(labelloc='t')
dot.attr(labeljust='l')
dot.attr(label='<\
         <table>\
         <tr><td colspan=\"3\">Krita dependencies</td></tr>\
         <tr>\
            <td><font color=\"black\">All</font></td>\
            <td><font color=\"magenta\">Linux</font></td>\
            <td><font color=\"blue\">Windows</font></td>\
         </tr>\
         {}{}\
         </table>>'.format(onlyLegengLine, skipLegendLine))

knownNodes = {}
knownEdges = {}

seedFile = arguments.seed_file

if not os.path.isabs(seedFile) and not os.path.exists(seedFile):
    seedFile = os.path.abspath(os.path.join(workingDirectory, seedFile))

dependencies = []
with open(seedFile, 'r') as f:
    dependencies = yaml.safe_load(f)

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

def addNodeWithSanityCheck(projectName):
    if not projectName in knownNodes:
        knownNodes[projectName] = 'red'

for projectName, dependants in linuxReverseDeps.items():
    addNodeWithSanityCheck(projectName)
    
    for dep in dependants:
        addNodeWithSanityCheck(dep)
        knownEdges[(projectName, dep)] = 'magenta'

for projectName, dependants in windowsReverseDeps.items():
    addNodeWithSanityCheck(projectName)
    for dep in dependants:
        addNodeWithSanityCheck(dep)

        color = 'blue'

        if (projectName, dep) in knownEdges:
            color = 'black'
        
        knownEdges[(projectName, dep)] = color

skippedProjects = set(arguments.skip_deps if not arguments.skip_deps is None else [])
onlyProjects = set(arguments.only_deps if not arguments.only_deps is None else [])

def allowDep(projectId):
    if skippedProjects and projectId in skippedProjects:
        return False
    if onlyProjects:
        if projectId in onlyProjects:
            return True

        edge = next(((a,b) for a, b in knownEdges.keys()
                     if
                     (a == projectId and b in onlyProjects) or
                     (b == projectId and a in onlyProjects)),
                     None)

        return not edge is None

    return True


for projectName, color in knownNodes.items():
    if not allowDep(projectName):
        continue

    dot.node(projectName, color = color)

for (projectName, dep), color in knownEdges.items():
    if not allowDep(projectName) or not allowDep(dep):
        continue

    # print ('{} -> {}: {}'.format(projectName, dep, color))
    dot.edge(projectName, dep, color = color)

# print(dot.source)

outputFile = arguments.output

if not os.path.isabs(outputFile):
    outputFile = os.path.abspath(os.path.join(workingDirectory, outputFile))

dot.render(outfile=outputFile, cleanup=True).replace('\\', '/')
