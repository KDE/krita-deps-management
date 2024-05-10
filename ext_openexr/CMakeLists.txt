cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openexr)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_openexr
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME openexr-v2.5.8.tar.gz
    URL https://github.com/AcademySoftwareFoundation/openexr/archive/v2.5.8.tar.gz
    URL_HASH SHA256=db261a7fcc046ec6634e4c5696a2fc2ce8b55f50aac6abe034308f54c8495f55

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DNAMESPACE_VERSIONING=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_openexr)
