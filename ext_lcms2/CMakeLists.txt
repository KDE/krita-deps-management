cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lcms2)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_lcms2
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/mm2/Little-CMS/archive/refs/tags/lcms2.18.tar.gz
    URL_HASH SHA256=4f52a4459a93ac02b88e49b04dc0679e52fc92d36d3b722e5a1a44dbe8118236

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Add-modern-CMake-toolchain.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Revert-Fix-LUT-based-optimization-on-8-bits.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTS=FALSE -DBUILD_UTILS=FALSE -DBUILD_STATIC=FALSE -DBUILD_PLUGINS=TRUE

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_lcms2)
