#!/usr/bin/env python3
import os
import sys
import argparse
import regex
import yaml

# Gather the command line arguments we need
parser = argparse.ArgumentParser(description='Verifies the metadata files')
parser.add_argument('--metadata-path', help='Path to the metadata to check', required=True)
args = parser.parse_args()

# Make sure our configuration file exists
if not os.path.exists( args.metadata_path ):
    print(f"Unable to locate specified metadata location: {args.metadata_path}")
    sys.exit(1)

# Regular expression used to validate project names
# Taken from Gitlab itself (with slight adaptation to be Python compatible)
projectRegex = regex.compile(r'^[\p{Alnum}\u00A9-\u1f9ff_][\p{Alnum}\p{Pd}\u00A9-\u1f9ff_\. ]*$', flags=regex.V1)

# Start a list of used project identifiers and names
projectIdentifiersInUse = []
projectNamesInUse = []

# Start going over the location in question...
for currentPath, subdirectories, filesInFolder in os.walk( args.metadata_path, topdown=False, followlinks=False ):
    # Do we have a metadata.yaml file?
    if 'metadata.yaml' not in filesInFolder:
        # We're not interested then....
        continue

    # Now that we know we have something to work with....
    # Lets load the current metadata up
    metadataPath = os.path.join( currentPath, 'metadata.yaml' )
    with open( metadataPath, 'r', encoding="utf-8" ) as metadataFile:
        metadata = yaml.safe_load( metadataFile )

    # Trim the base path to the metadata off to make it a bit nicer to read
    currentLocation = currentPath[len(args.metadata_path):]

    # check sanity of the description and make sure that it is less then 250
    # (part of gitlab restriction)
    if metadata['description'] is not None and len(metadata['description']) > 250:
        print(currentLocation + ": Project description is longer than 250 characters")

    # check the description and ensure that it is not empty
    # currently warning, but still best to list it out
    if metadata['description'] is not None and len(metadata['description']) == 0:
        print(currentLocation + ": Project description is empty")

    # Check if name have supported characters only
    if projectRegex.match(metadata['name']) is None:
        print(currentLocation + ": Project name contains characters not allowed by Gitlab - " + metadata['name'])

    # Make sure the name is not already in use
    if metadata['name'] in projectNamesInUse:
        print(currentLocation + ": Project name is already in use - " + metadata['name'])

    # Make sure that identifier is not empty
    identifier = metadata.get('identifier')
    if identifier is None:
        print(currentLocation + ": CRITICAL ERROR - Project identifier is not set")
        sys.exit(1)

    # Make sure the identifier is not in use already
    if identifier in projectIdentifiersInUse:
        print(currentLocation + ": CRITICAL ERROR - Project identifier is already in use - " + metadata['identifier'])
        sys.exit(1)

    # All checks done for this project
    # Add it to the list of identifiers and names in use
    projectNamesInUse.append( metadata['name'] )
    projectIdentifiersInUse.append( identifier )

# All done!
sys.exit(0)
