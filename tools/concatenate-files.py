#!/usr/bin/env python3
import argparse
import sys

parser = argparse.ArgumentParser(description="Concatenate multiple input files into a single output file in cross-platform way")
parser.add_argument('-i', '--input', action='append', required=True, help="Path to an input file. Can be specified multiple times.")
parser.add_argument('-o', '--output', required=True, help="Path to the output file.")

args = parser.parse_args()

try:
    with open(args.output, 'w', encoding='utf-8') as outfile:
        for index, filePath in enumerate(args.input):
            # Write a newline to split the files
            if index > 0:
                outfile.write('\n')

            with open(filePath, 'r', encoding='utf-8') as infile:
                outfile.write(infile.read())

except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
