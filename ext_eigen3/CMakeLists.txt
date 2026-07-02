cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_eigen3)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_eigen3
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz
    URL_HASH SHA256=e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTING=OFF
        # we don't use BLAS and LAPACK optimizations for now and they
        # seem to cause some troubles for gcc to compile this thing
        -DEIGEN_BUILD_BLAS=OFF -DEIGEN_BUILD_LAPACK=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_eigen3)
