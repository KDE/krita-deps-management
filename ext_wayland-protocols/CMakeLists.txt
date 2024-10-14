cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_wayland-protocols)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_wayland-protocols
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.38/downloads/wayland-protocols-1.38.tar.xz
    URL_HASH SHA256=ff17292c05159d2b20ce6cacfe42d7e31a28198fa1429a769b03af7c38581dbe

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=false
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_wayland-protocols)