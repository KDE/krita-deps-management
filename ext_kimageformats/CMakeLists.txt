cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kimageformats)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kimageformats
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kimageformats-6.25.0.tar.xz
    URL_HASH SHA256=dfa0e9b16a288a8f94233afcbaffc87c1c5ddc037aca643943aab5a67685f26b

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_TESTING=OFF
        -DKIMAGEFORMATS_JXL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenEXR=TRUE
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kimageformats)
