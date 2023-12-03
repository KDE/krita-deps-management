cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_patch)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_patch
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL http://files.kde.org/krita/build/dependencies/patch-2.5.9-7-bin.zip
    URL_MD5 b9c8b31d62f4b2e4f1887bbb63e8a905
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E echo deploying patch.exe binary
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${EXTPREFIX}/bin
        COMMAND ${CMAKE_COMMAND} -DSRC=bin/patch.exe -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
        COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/patch.exe.manifest -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 1
)

krita_add_to_ci_targets(ext_patch)
