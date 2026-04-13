cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kwidgetsaddons)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kcolorscheme
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kcolorscheme-6.25.0.tar.xz
    URL_HASH SHA256=95a8a37817765f910c59b269a9958557505b99ff698fd6d220bcb166d5e302f5

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kcolorscheme)
