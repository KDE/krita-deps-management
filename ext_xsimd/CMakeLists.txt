cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_xsimd)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_xsimd
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    DOWNLOAD_NAME xsimd-13.1.0.tar.gz
    URL https://github.com/xtensor-stack/xsimd/archive/refs/tags/13.1.0.tar.gz
    URL_HASH SHA256=88c9dc6da677feadb40fe09f467659ba0a98e9987f7491d51919ee13d897efa4

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_xsimd)
