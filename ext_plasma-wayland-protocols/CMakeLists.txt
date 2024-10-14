cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_plasma-wayland-protocols)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)


ExternalProject_Add(
    ext_plasma-wayland-protocols
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/KDE/plasma-wayland-protocols/archive/refs/tags/v1.13.0.tar.gz
    URL_HASH SHA256=b4441a673cfb5dcdef921a2793b2dc6de6c4bed00ac005814376fc16caf1a016

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_plasma-wayland-protocols)
