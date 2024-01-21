#!/usr/bin/python3
import os
import sys
import yaml
import argparse
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, Dependencies, PlatformFlavor
from components.CiConfigurationUtils import *

import graphviz


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

linuxPlatform = PlatformFlavor.PlatformFlavor('Linux')
linuxDependencyResolver = prepareDependenciesResolver(linuxPlatform)
linuxReverseDeps = genReverseDeps(workingDirectory, linuxDependencyResolver, arguments.branch)

windowsPlatform = PlatformFlavor.PlatformFlavor('Windows')
windowsDependencyResolver = prepareDependenciesResolver(windowsPlatform)
windowsReverseDeps = genReverseDeps(workingDirectory, windowsDependencyResolver, arguments.branch)

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
