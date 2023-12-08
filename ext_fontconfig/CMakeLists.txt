cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_freetype)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)


kis_ExternalProject_Add_with_separate_builds_apple(
    ext_fontconfig
    MESON
    URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.0.tar.gz
    URL_HASH SHA256=b8f607d556e8257da2f3616b4d704be30fd73bd71e367355ca78963f9a7f0434

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-fontconfig-Do-not-create-symlinks-microsoft-23735.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-fontconfig-Enable-tool-CLI-option-handling-24553.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Add-default-fonts-path-for-Android.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Always-find-files-when-using-DESTDIR.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
        -Ddoc=disabled
        -Dcache-build=disabled
        -Dtests=disabled
        ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_fontconfig)