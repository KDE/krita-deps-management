cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_ocio)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_ocio
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME OpenColorIO-v2.3.0.tar.gz
    URL https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/v2.3.0.tar.gz
    URL_HASH SHA256=32b7be676c110d849a77886d8a409159f0367309b2b2f5dae5aa0c38f42b445a

    INSTALL_DIR ${EXTPREFIX}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DOCIO_BUILD_NUKE:BOOL=OFF -DOCIO_BUILD_DOCS:BOOL=OFF -DOCIO_BUILD_TESTS:BOOL=OFF -DOCIO_BUILD_GPU_TESTS:BOOL=OFF -DOCIO_BUILD_PYTHON:BOOL=OFF -DOCIO_INSTALL_EXT_PACKAGES=MISSING -DOCIO_BUILD_APPS=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_ocio)
