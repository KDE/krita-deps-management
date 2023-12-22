#!/usr/bin/python3
import os
import yaml
import argparse

# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to run builds for multiple projects on CI')
parser.add_argument('-s','--seed-file', type=str, help='Seed file for generation of the deps', required=True)
parser.add_argument('-o','--output-file', type=str, help='Output file for saving the result')
arguments = parser.parse_args()

workingDirectory = os.getcwd()

configuration = {}

localConfigFilePath = os.path.join(workingDirectory, '.kde-ci.yml')
if os.path.exists(localConfigFilePath):
    with open(localConfigFilePath, 'r') as f:
        configuration = yaml.safe_load(f)

if not os.path.exists(arguments.seed_file):
    print('ERROR: seed file does not exist: {}'.format(arguments.seed_file))

dependencies = []
with open(arguments.seed_file, 'r') as f:
    dependencies = yaml.safe_load(f)

configuration['Dependencies'] = dependencies

if not arguments.output_file:
    print (yaml.dump(configuration, indent = 2))
else:
    with open(arguments.output_file, 'w') as f:
        yaml.dump(configuration, f, indent = 2)
