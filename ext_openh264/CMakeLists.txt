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
    URL https://github.com/cisco/openh264/archive/v2.3.1.tar.gz
    URL_HASH SHA256=453afa66dacb560bc5fd0468aabee90c483741571bca820a39a1c07f0362dc32

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-libopenh264-Enable-PIC-for-the-assembler-code-on-x86.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dtests=disabled
            ${EXTRA_MESON_FLAGS}
)

krita_add_to_ci_targets(ext_openh264)
