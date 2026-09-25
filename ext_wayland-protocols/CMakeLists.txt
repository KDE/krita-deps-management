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
    URL https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.48/downloads/wayland-protocols-1.48.tar.xz
    URL_HASH SHA256=398036ac0eb6484982ddbde7ff86848d753231f9cdeeae983f06b52946625aa1

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=false
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_wayland-protocols)