#
# Usage: cmake -DPREFIX=/prefix/path -P fix-python-install-scheme.cmake
#

#
# On Windows Python hardcodes the installation scheme to be ${PREFIX}/Scripts
# and ${PREFIX}/Lib, but we, in Krita, use the posix scheme.
#
# It is not possible to change the scheme in Python without recompiling it
# (as of Python 3.10), so we just fix the scheme after installation.
#

# for IN_LIST to be available
cmake_minimum_required(VERSION 3.3)

if (DEFINED ENV{DESTDIR})
    set(DESTDIR $ENV{DESTDIR})
    cmake_path(ABSOLUTE_PATH PREFIX NORMALIZE)
    cmake_path(ABSOLUTE_PATH DESTDIR NORMALIZE)

    cmake_path(GET PREFIX RELATIVE_PART RELATIVE_PREFIX)
    # message("prefix ${PREFIX}")
    # message("relprefix ${RELATIVE_PREFIX}")

    cmake_path(APPEND NEWPREFIX ${DESTDIR} ${RELATIVE_PREFIX})
    set(PREFIX ${NEWPREFIX})
    # message("finalprefix ${PREFIX}")
endif()

file(GLOB PREFIX_CONTENT LIST_DIRECTORIES TRUE RELATIVE ${PREFIX} "${PREFIX}/*")

if ("Scripts" IN_LIST PREFIX_CONTENT)
    if (NOT "bin" IN_LIST PREFIX_CONTENT)
        message(STATUS "Renaming ./Scripts -> ./bin at ${PREFIX}")
        file(RENAME "${PREFIX}/Scripts" "${PREFIX}/bin")
    else()
        file(COPY "${PREFIX}/Scripts" DESTINATION "${PREFIX}/bin")
        file(REMOVE_RECURSE "${PREFIX}/Scripts/")
    endif()
endif()

if ("Lib" IN_LIST PREFIX_CONTENT)
    if (NOT "lib" IN_LIST PREFIX_CONTENT)
        message(STATUS "Renaming ./Lib -> ./lib at ${PREFIX}")
        file(RENAME "${PREFIX}/Lib" "${PREFIX}/lib")
    else()
        file(COPY "${PREFIX}/Lib/" DESTINATION "${PREFIX}/lib")
        file(REMOVE_RECURSE "${PREFIX}/Lib/")
    endif()
endif()
