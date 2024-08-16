#!/usr/bin/python3
import sys
import os
import yaml
import argparse

# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to run builds for multiple projects on CI')
parser.add_argument('seedfile', type=str, help='Seed file for generation of the deps')
parser.add_argument('-s','--src-branch', type=str, default='master', help='The name of the branch to rename', required=False)
parser.add_argument('-d','--dst-branch', type=str, default='master', help='Desired branch name', required=True)
parser.add_argument('-o','--output-file', type=str, help='Output seed file', required=False)
parser.add_argument('-p','--print', action='store_true', help='Print the resulting seed file', required=False)
arguments = parser.parse_args()

workingDirectory = os.getcwd()

configuration = {}

seedFilePath = os.path.abspath(arguments.seedfile)
if not os.path.exists(seedFilePath):
    print('ERROR: seed file does not exist: {}'.format(seedFilePath))
    sys.exit(1)

if arguments.output_file is None:
    arguments.output_file = arguments.seedfile

with open(seedFilePath, 'r') as f:
    configuration = yaml.safe_load(f)

for item in configuration:
    if 'require' in item:
        for dep, branch in item['require'].items():
            if branch == arguments.src_branch:
                item['require'][dep] = arguments.dst_branch

with open(arguments.output_file, 'w') as f:
    yaml.dump(configuration, f, indent = 2)

if arguments.print:
    print (yaml.dump(configuration, indent = 2))
