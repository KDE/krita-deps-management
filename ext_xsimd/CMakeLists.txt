cmake_minimum_required(VERSION 3.29)

project(ext_xsimd)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_xsimd
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    DOWNLOAD_NAME xsimd-13.1.0.tar.gz
    URL https://github.com/xtensor-stack/xsimd/archive/refs/tags/14.1.0.tar.gz
    URL_HASH SHA256=8da77b66214e73565f6111ba494322c853552b7b40cff69779b42e2100eed16f

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_xsimd)
