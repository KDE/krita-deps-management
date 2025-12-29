cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libheif)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_libheif
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL https://github.com/strukturag/libheif/releases/download/v1.20.2/libheif-1.20.2.tar.gz
    URL_HASH SHA256=68ac9084243004e0ef3633f184eeae85d615fe7e4444373a0a21cebccae9d12a

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DWITH_EXAMPLES=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libheif)
