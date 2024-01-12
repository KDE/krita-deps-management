#!/usr/bin/python3
import os
#import yaml
import argparse
import sys
import platform
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ci-utilities'))
from components import CommonUtils, EnvFileUtils

# Capture our command line parameters
parser = argparse.ArgumentParser(description='Utility to set up the environment for the split deps build')
parser.add_argument('-r','--root', type=str, help='Root directory for the environment (default: current working directory)')
parser.add_argument('-p','--path', action='append', help='Extra path to be added to the environment')
parser.add_argument('-v','--venv', type=str, help='Path to the venv python environment')
parser.add_argument('-s','--shared-install', type=str, help='Path to the shared install folder (default: no shared install enabled)')
parser.add_argument('-o','--output-file', type=str, help='Output file base name for the environment file (.bat suffix is added automatically)', default='base-env')
arguments = parser.parse_args()

workingDirectory = os.getcwd()

if not arguments.root is None:
    workingDirectory = os.path.abspath(arguments.root)

print ('## Environment root: {}'.format(workingDirectory))

environmentUpdate = {}

print ('## Generating cache folders...')
for dir in ['cache', 'ccache', os.path.join('cache', 'downloads')]:
    dirPath = os.path.join(workingDirectory, dir)
    
    if not os.path.isdir(dirPath):
        os.mkdir(dirPath)
        print ('##     created: {}'.format(dirPath))

sharedInstallDirectory = None

if not arguments.shared_install is None:
    if not os.path.isabs(arguments.shared_install):
        sharedInstallDirectory = os.path.join(workingDirectory, arguments.shared_install)
    else:
        sharedInstallDirectory = arguments.shared_install

    if not os.path.isdir(sharedInstallDirectory):
        os.mkdir(sharedInstallDirectory)
    print ('## Created shared install folder: {}'.format(sharedInstallDirectory))


repoBaseDirectory = os.path.abspath(os.path.join(CommonUtils.scriptsBaseDirectory(), '..'))

environmentUpdate['KDECI_CACHE_PATH'] = os.path.join(workingDirectory, 'cache')
environmentUpdate['KDECI_CC_CACHE'] = os.path.join(workingDirectory, 'ccache')
environmentUpdate['EXTERNALS_DOWNLOAD_DIR'] = os.path.join(workingDirectory, 'cache', 'downloads')

environmentUpdate['KDECI_GITLAB_SERVER'] = 'https://invent.kde.org/'
environmentUpdate['KDECI_PACKAGE_PROJECT'] = 'dkazakov/krita-ci-artifacts-windows-qt5.15'

environmentUpdate['KDECI_BUILD_TYPE'] = 'Release'
environmentUpdate['KDECI_BUILD_TARGET'] = 'ext_build'
environmentUpdate['KDECI_INSTALL_TARGET'] = 'ext_install'
environmentUpdate['KDECI_GLOBAL_CONFIG_OVERRIDE_PATH'] = os.path.join(repoBaseDirectory, 'global-config.yml')
environmentUpdate['KDECI_REPO_METADATA_PATH'] = os.path.join(repoBaseDirectory, 'repo-metadata')

if not sharedInstallDirectory is None:
    environmentUpdate['KDECI_SHARED_INSTALL_PATH'] = sharedInstallDirectory

for var, value in environmentUpdate.items():
    print ('{} -> {}'.format(var, value))

activationScripts = []
deactivationScripts = []

if not arguments.venv is None:
    if platform.system() == "Windows":
        activationScripts.append(os.path.join(arguments.venv, 'Scripts', 'activate.bat'))
        deactivationScripts.append(os.path.join(arguments.venv, 'Scripts', 'deactivate.bat'))
    else:
        activationScripts.append(os.path.join(arguments.venv, 'bin', 'activate'))

    for script in activationScripts + deactivationScripts:
        if not os.path.exists(script):
            print ('ERROR: cannot find activation/deactivation script: {}'.format(script))
            raise('Cannot find venv script')

extraPathValues = [os.path.abspath(path) for path in arguments.path]

for value in extraPathValues:
    print ('PATH += {}'.format(value))

EnvFileUtils.writeEnvFile(workingDirectory, arguments.output_file,
            environmentUpdate,
            extraActivationScripts = activationScripts,
            extraDeactivationScripts = deactivationScripts,
            environmentAppend={'PATH': extraPathValues})
