cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_zlib)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_lcms2
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/mm2/Little-CMS/releases/download/lcms2.14/lcms2-2.14.tar.gz
    URL_HASH SHA256=28474ea6f6591c4d4cee972123587001a4e6e353412a41b3e9e82219818d5740

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Add-modern-CMake-toolchain.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Revert-Fix-LUT-based-optimization-on-8-bits.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTS=FALSE -DBUILD_UTILS=FALSE -DBUILD_STATIC=FALSE -DBUILD_PLUGINS=TRUE

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_lcms2)