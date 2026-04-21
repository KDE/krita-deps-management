cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openexr)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_openexr
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/AcademySoftwareFoundation/openexr/releases/download/v3.4.10/openexr-3.4.10.tar.gz
    URL_HASH SHA256=2e054a8f5030c25d1585cbfa537feaaf86d69388b75c00d96c3a91f676e88cbe

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DNAMESPACE_VERSIONING=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_openexr)
