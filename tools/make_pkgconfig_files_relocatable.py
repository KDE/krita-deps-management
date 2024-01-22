# =================
# Attempt to fix all files recursively matching */pkgconfig/*.pc in $DESTDIR
# in a way that makes them portable/relocatable and thus suitable for packaging.
# By no means handles all cases, just common ones.
#
# This is largely achieved by utilizing ${pcfiledir} to ensure paths are relative
# to the .pc file itself, and attempt to verify that there are no other absoulte,
# system-dependent paths present in the files.
#
# We also substitute a couple of special cases of absolute paths that are deemed
# reasonable to expect gcc to find on its own, such as libatomic and libz,
# and attempt to fix paths that look like they are in the build directory rather
# than the install directory.
# =================

import os
import re
import sys
from collections import defaultdict
import glob

# unquoted absolute unix paths are hard to distinguish, especially if they are in a linker statement such as -lm/bad/times (if we at the same time dont want to confuse them with relative paths -lm../this/is/not/an/abspath)
# some things may actually also like an abspath, and even be an existing path on a given system, but be used as an infix (eg /usr). there are times where we are forced to simply make an assumption
# we are not going to handle devious cases like " or ' in file names
# we are also ignoring the possibility of escaped whitespace in unquoted filenames ("\ ")

# so.. the idea for this mask is to use it after all other masks, and then check if the characters immediately preceeding it are ".." or a ${var}. if neither, check if its a path inside the install prefix and if so, we actually have path we need to handle. if it's not within the install prefix, we have to ignore it, as it might not be a path at all (and we cannot test it because it may be a path that does not yet exist)
unquotedAbsPathCandidate = re.compile("(/[^\\s]+)")

quotedAbsPath = re.compile("([\"'])(/[^\"]*)\\1")
# we are also not handling a windows path that is just a drive name without a path serperator (plain "C:")
winUnquotedAbsPath = re.compile("([a-zA-Z]:[\\\\/][^<>:\\?\\|\\*\"\\s]*)")
winQuotedAbsPath = re.compile("\"([a-zA-Z]:[\\\\/][^<>:\\?\\|\\*\"]*)\"")


pcVarFormat = "\\$\\{([^\\{\\}]+)\\}"
pcVarRegex = re.compile(pcVarFormat)
pcVarPrefixRegex = re.compile(pcVarFormat + "$")

# globals
line = ""
lineNr = -1
currentFileName = ""
myvars = defaultdict(lambda: "")
DESTDIR = ""
PATH_TO_ARCHIVE = ""
installPath = ""

# copied from https://invent.kde.org/sysadmin/ci-utilities/-/blob/master/components/CommonUtils.py
# Converts a path to a relative one, to allow for it to be passed to os.path.join
# This is primarily relevant on Windows, where full paths have the drive letter, and thus can be simply joined together as you can on Unix systems
def stripDriveOrRoot(path):
    # If we're on Windows, chop the drive letter off...
    if sys.platform == "win32":
        return path[3:]

    # Otherwise we just drop the starting slash off
    return path[1:]

def substitute(s):
    limit = 99
    while True:
        repeat = False

        m = pcVarRegex.search(s)

        if m and m[1]:
            if m[1] == 'pc_sysrootdir':
                error("${pc_sysrootdir} is not implemented")

            # we need to not accidentally modify myvars here
            value = m[1] in myvars and myvars[m[1]] or ""
            s = s[:m.start(0)] + value + s[m.end(0):]
            repeat = True

        limit = limit - 1
        if limit < 0:
            error("probably ran into recursion")

        if not repeat:
            break

    return s

# normalization for windows to avoid accidents around case and seperator character
def norm(path):
    if not sys.platform == "win32":
        return path

    return os.path.normcase(path).replace('\\', '/')

def norm_abs(path):
    return norm(os.path.normpath(path))

def error(msg):
    print("ERROR:", msg)
    print("  " + currentFileName + ":" + str(lineNr) + ":")
    print("  " + line)
    sys.exit(-1)

def best_prefix(path):
    bestVar = ""
    bestRelPath = ""
    bestDotDot = 9999

    for k,v in myvars.items():
        candidate = norm(os.path.normpath(substitute(v)))
        normpath = norm(os.path.normpath(path))
        l = len(os.path.commonprefix([normpath, candidate]))
        relpath = os.path.relpath(normpath, candidate)
        dd = relpath.count("..")
        if l > 0 and dd <= bestDotDot:
            # bias towards prefix
            if dd == bestDotDot and bestVar == "prefix":
                continue
            
            bestDotDot = dd
            bestRelPath = norm(relpath)
            bestVar = k

    if bestVar == "":
        error("failed to create relative prefix for path: " + path)

    separator = "/"
    if myvars[bestVar].endswith('/') or myvars[bestVar].endswith('\\') or bestRelPath == ".":
        separator = ""
    if bestRelPath == ".":
        bestRelPath = ""

    return "${" + bestVar + "}" + separator + bestRelPath

def make_path_relocatable(path):
    testpath = norm(os.path.normpath(path))

    if len(os.path.normpath(os.path.commonprefix([testpath, installPath]))) != len(installPath):
        # on windows, QT references the _build directory in some places for unknown reasons, we just strip that down to the raw library file name and hope for the best
        if sys.platform == 'win32':
            # TODO: guard this better against a random _build directory higher up the chain if possible (this is a little convoluted due to shared/not shared install/build dirs)
            # also maybe test if the file exists in archivedir/lib
            # also actually test this
            m = re.match(".*[/\\\\]_build[/\\\\].*[/\\\\]([\\w.]+\\.[\\w]+)$", testpath)
            if m and m[1]:
                return m[1]

        # TODO: fold this into a list of lists
        # handle some specific system deps that creep in from ffmpeg
        m = re.search("/libatomic\\.(a|so)$", testpath)
        if m:
            return "-latomic"
        m = re.search("/libz\\.(a|so)$", testpath)
        if m:
            return "-lz"
        m = re.search("/libbz2\\.(a|so)$", testpath)
        if m:
            return "-lbz2"

        error("path not within install prefix[" + installPath + "]:\n" + path)

    return best_prefix(path)

def make_relocatable(s):
    limit = 99
    pos = 0 # we only advance pos if we found something that looks like an unqoted unix path but didn't handle
    while True:
        wrap = ""
        match = None
        matchIndex = 1
        remaining = s[pos:]

        limit = limit - 1
        if limit < 0:
            error("probably ran into recursion")

        if sys.platform == 'win32':
            m = winQuotedAbsPath.search(remaining)
            if m and m[1]:
                match = m
                wrap = '"'
            else:
                m = winUnquotedAbsPath.search(remaining)
                if m and m[1]:
                    match = m
        else:
            m = quotedAbsPath.search(remaining)
            if m and m[1] and m[2]:
                match = m
                matchIndex = 2
                wrap = m[1]
            else:
                m = unquotedAbsPathCandidate.search(remaining)
                if m and m[1]:
                    prefix = remaining[:m.start(1)]
                    m2 = pcVarPrefixRegex.search(prefix)
                    if not m2 and not prefix.endswith("..") and m[1].startswith(installPath):
                        match = m
                    else:
                        pos = pos + m.end(0)
                        continue

        if match:
            s = s[:pos + match.start(0)] + wrap + make_path_relocatable(match[matchIndex]) + wrap + s[pos + match.end(0):]
        else:
            break

    return s

def assign(lhs, rhs):
    global myvars
    myvars[lhs] = rhs.rstrip("\r\n")

ignoredDefs = ["conflicts", "name", "description", "version", "requires", "url"]
handledDefs = ["libs", "cflags"]

if not 'DESTDIR' in os.environ:
    print("ERROR: DESTDIR not set")
    sys.exit(-1)
DESTDIR = norm_abs(os.environ['DESTDIR'])

if not 'KDECI_PATH_TO_ARCHIVE' in os.environ:
    print("ERROR: KDECI_PATH_TO_ARCHIVE not set")
    sys.exit(-1)
PATH_TO_ARCHIVE = norm_abs(os.environ['KDECI_PATH_TO_ARCHIVE'])

installPath = (sys.platform == 'win32' and PATH_TO_ARCHIVE[:2] or "") + PATH_TO_ARCHIVE[len(DESTDIR):]

for subDir in ["lib/pkgconfig", "share/pkgconfig"]:
    stagingPcFileDir = norm(os.path.join(PATH_TO_ARCHIVE, subDir))
    if not os.path.exists(stagingPcFileDir):
        continue

    os.chdir(stagingPcFileDir)
    for currentFileName in glob.glob("*.pc"):
        myvars = defaultdict(lambda: "")
        assign("pcfiledir", norm(os.path.join(installPath, subDir)))

        print("processing " + currentFileName + "...")

        outPc = ""
        with open(currentFileName, 'r') as file:
            input = file.read()

        lineNr = 0
        for line in input.splitlines(keepends=True):
            lineNr += 1
            trimedLine = line.strip()

            if len(trimedLine) <= 0 or trimedLine[0] == '#':
                outPc += line
                continue

            firstColon = line.find(':')
            firstEquals = line.find('=')

            isDefinition = False
            isAssignment = False
            if firstColon < 0 and firstEquals < 0:
                outPc += line
                continue
            elif firstEquals < 0 or (firstColon > 0 and firstColon < firstEquals):
                isDefinition = True
                splitPos = firstColon
            else:
                isAssignment = True
                splitPos = firstEquals


            if splitPos <= 0:
                outPc += line
                continue

            lhsOrig = line[:splitPos]
            lhs = lhsOrig.strip()
            rhs = line[splitPos+1:]

            if len(lhs) <= 0 or len(rhs.strip()) <= 0:
                outPc += line
                continue

            if isDefinition:
                lhs = lhs.lower()
                if lhs.startswith(tuple(ignoredDefs)):
                    outPc += line
                    continue

                if lhs.startswith(tuple(handledDefs)):
                    reloc = make_relocatable(rhs)
                    outPc += lhsOrig + ':' + reloc
                else:
                    print("WARNING: ignoring unknown definition:", line)
                    outPc += line
            else:
                reloc = make_relocatable(rhs)
                outLine = lhsOrig + "=" + reloc
                outPc += outLine
                assign(lhs, reloc)

        if (input != outPc):
            print("writing modified pc file: " + currentFileName)
            with open(currentFileName, 'w') as file:
                file.write(outPc)
