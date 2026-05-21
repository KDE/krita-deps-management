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
    URL https://gitlab.freedesktop.org/wayland/wayland/-/releases/1.25.0/downloads/wayland-1.25.0.tar.xz
    URL_HASH SHA256=c065f040afdff3177680600f249727e41a1afc22fccf27222f15f5306faa1f03

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=false
            -Ddocumentation=false
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_wayland)