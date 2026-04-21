cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lzma)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

##
# Be careful when updating LZMA:
# Versions 5.6.0 and 5.6.1 are backdored (CVE-2024-3094)
##

if (WIN32)
    ExternalProject_Add( ext_lzma
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/tukaani-project/xz/releases/download/v5.8.3/xz-5.8.3-windows.zip
        URL_HASH SHA256=8d0048ee51177b11ef1613959c2a268c951f4e7f6fb3706e681e00e34bb6d5e3

        INSTALL_DIR ${EXTPREFIX}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying 64-bit liblzma.dll
        INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin_x86-64/liblzma.dll -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin_x86-64/liblzma.a -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include/lzma.h -DDST=${EXTPREFIX}/include/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include/lzma -DDST=${EXTPREFIX}/include/lzma/ -P ${KRITA_CI_INSTALL_DIRECTORY}

        UPDATE_COMMAND ""
    )
else ()
    ExternalProject_Add( ext_lzma
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/tukaani-project/xz/releases/download/v5.8.3/xz-5.8.3.tar.gz
        URL_HASH SHA256=3d3a1b973af218114f4f889bbaa2f4c037deaae0c8e815eec381c3d546b974a0

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}
    )

endif ()

krita_add_to_ci_targets(ext_lzma)
