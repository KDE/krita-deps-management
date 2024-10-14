cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kimageformats)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kimageformats
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.7/kimageformats-6.7.0.tar.xz
    URL_HASH SHA256=722850648ac167e4c0ee631571fde49e9fd15d004a127dd804a14f9f579b731f

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_TESTING=OFF
        -DKIMAGEFORMATS_JXL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenEXR=TRUE
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kimageformats)
