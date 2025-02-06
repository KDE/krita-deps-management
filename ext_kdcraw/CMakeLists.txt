cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kdcraw)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(ext_kdcraw
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/release-service/24.12.2/src/libkdcraw-24.12.2.tar.xz
    URL_HASH SHA256=ef05c88669201701556eac097f51cf264a297d3b45db8c06465f2345ff5ceb96

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_SHARED_LIBS=OFF
        -DQT_MAJOR_VERSION=6
        -DBUILD_TESTING=OFF
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kdcraw)
