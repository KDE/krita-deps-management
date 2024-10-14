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
    URL https://download.kde.org/stable/frameworks/6.7/karchive-6.7.0.tar.xz
    URL_HASH SHA256=eb4243e627f51f1224a99af5d0a6f8e309f9e5dbb7478f7a78e34e2b8541398a

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}
        ${_karchive_extra_flags}
        -DWITH_LIBZSTD=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_karchive)
