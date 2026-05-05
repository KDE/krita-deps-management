cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lcms2)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_lcms2
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/mm2/Little-CMS/archive/refs/tags/lcms2.19.tar.gz
    URL_HASH SHA256=6acc3eb5fac194acc85331194133ad1d4a60419dad16b3bc225a7d27380a5b3a

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Revert-Fix-LUT-based-optimization-on-8-bits.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTS=FALSE -DBUILD_UTILS=FALSE -DBUILD_STATIC=FALSE -DBUILD_PLUGINS=TRUE

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_lcms2)
