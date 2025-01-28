cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_giflib)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_giflib
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://downloads.sourceforge.net/project/giflib/giflib-5.2.1.tar.gz
    URL_MD5 6f03aee4ebe54ac2cc1ab3e4b0a049e5

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-vcpkg-CMake-toolchain.patch
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_utils=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_giflib)
