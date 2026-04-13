cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_karchive)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set (_karchive_extra_flags "")
if (ANDROID)
    set(_karchive_extra_flags "-DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=1")
endif()

ExternalProject_Add(
    ext_karchive
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/karchive-6.25.0.tar.xz
    URL_HASH SHA256=123a268352ab63d548ba5e3c3e8fbf1d737025e4c5189821cf10e3328ab4de15

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}
        ${_karchive_extra_flags}
        -DWITH_LIBZSTD=OFF
        -DWITH_BZIP2=OFF
        -DWITH_LIBLZMA=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_karchive)
