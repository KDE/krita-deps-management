cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_plasma-wayland-protocols)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)


ExternalProject_Add(
    ext_plasma-wayland-protocols
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://invent.kde.org/libraries/plasma-wayland-protocols/-/archive/v1.21.0/plasma-wayland-protocols-v1.21.0.tar.gz
    URL_HASH SHA256=2e6cea3529c0965c0147aee30cdd7e5725957ca441043579288803246a3a5758

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_plasma-wayland-protocols)
