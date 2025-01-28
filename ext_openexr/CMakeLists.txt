cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openexr)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_openexr
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME openexr-v2.5.9.tar.gz
    URL https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v2.5.9.tar.gz
    URL_HASH SHA256=05bb9c2da3ff3508eee51c30f59c7f2c59bf068f3b636d12d5991e8bbaf13e01

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DNAMESPACE_VERSIONING=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_openexr)
