cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openh264)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_openh264
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME openh264-v2.6.0.tar.gz
    URL https://github.com/cisco/openh264/archive/refs/tags/v2.6.0.tar.gz
    URL_HASH SHA256=558544ad358283a7ab2930d69a9ceddf913f4a51ee9bf1bfb9e377322af81a69

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=disabled
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_openh264)
