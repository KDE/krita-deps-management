cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_ocio)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_ocio
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME OpenColorIO-v2.5.1.tar.gz
    URL https://github.com/AcademySoftwareFoundation/OpenColorIO/releases/download/v2.5.1/OpenColorIO-2.5.1.tar.gz
    URL_HASH SHA256=49ab04d023d7a7a7237e24f2cfead3171b0ff7f466ce20e6e32859ec8c7cc94b

    INSTALL_DIR ${EXTPREFIX}

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-linking-to-self-built-deps-on-Windows-Clang.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DOCIO_BUILD_NUKE:BOOL=OFF -DOCIO_BUILD_DOCS:BOOL=OFF -DOCIO_BUILD_TESTS:BOOL=OFF -DOCIO_BUILD_GPU_TESTS:BOOL=OFF -DOCIO_BUILD_PYTHON:BOOL=OFF -DOCIO_INSTALL_EXT_PACKAGES=MISSING -DOCIO_BUILD_APPS=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_ocio)
