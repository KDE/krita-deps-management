cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kitemviews)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kitemviews
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kitemviews-6.25.0.tar.xz
    URL_HASH SHA256=b57f38d6fd184a4b260d0b35d76f6c0fb96bdd80475e3ca7d4151023730e5d3d

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kitemviews)
