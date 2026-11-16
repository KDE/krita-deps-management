cmake_minimum_required(VERSION 3.29)

project(ext_lcms2)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_lcms2
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/mm2/Little-CMS/releases/download/lcms2.20/lcms2-2.20.tar.gz
    URL_HASH SHA256=18ff5504fa9cc8a2b1f3591180d90ead16c8a2ea78e530523b46eab70e1ca6b9

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Revert-Fix-LUT-based-optimization-on-8-bits.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTS=FALSE -DBUILD_UTILS=FALSE -DBUILD_STATIC=FALSE -DBUILD_PLUGINS=TRUE

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_lcms2)
