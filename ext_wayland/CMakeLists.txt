cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_wayland)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_wayland
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://gitlab.freedesktop.org/wayland/wayland/-/releases/1.23.1/downloads/wayland-1.23.1.tar.xz
    URL_HASH SHA256=864fb2a8399e2d0ec39d56e9d9b753c093775beadc6022ce81f441929a81e5ed

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=false
            -Ddocumentation=false
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_wayland)