cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_eigen3)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_eigen3
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
    URL_HASH SHA256=8586084f71f9bde545ee7fa6d00288b264a2b7ac3607b974e54d13e7162c1c72

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTING=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_eigen3)
