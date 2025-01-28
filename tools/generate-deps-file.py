#!/usr/bin/python3
import os
import sys
import yaml
import argparse

# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to run builds for multiple projects on CI')
parser.add_argument('-s','--seed-file', nargs='+', type=str, help='Seed file for generation of the deps', required=True)
parser.add_argument('-o','--output-file', type=str, help='Output file for saving the result')
arguments = parser.parse_args()

workingDirectory = os.getcwd()

configuration = {}

localConfigFilePath = os.path.join(workingDirectory, '.kde-ci.yml')
if os.path.exists(localConfigFilePath):
    with open(localConfigFilePath, 'r') as f:
        configuration = yaml.safe_load(f)

for seed_file in arguments.seed_file:
    if not os.path.exists(seed_file):
        print('ERROR: seed file does not exist: {}'.format(seed_file))
        sys.exit(1)

dependencies = []
for seed_file in arguments.seed_file:
    with open(seed_file, 'r') as f:
        dependencies.extend(yaml.safe_load(f))

configuration['Dependencies'] = dependencies

if not arguments.output_file:
    print (yaml.dump(configuration, indent = 2))
else:
    with open(arguments.output_file, 'w') as f:
        yaml.dump(configuration, f, indent = 2)
