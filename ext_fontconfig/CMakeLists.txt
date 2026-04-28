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
    URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.16.0.tar.xz
    URL_HASH SHA256=6a33dc555cc9ba8b10caf7695878ef134eeb36d0af366041f639b1da9b6ed220

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Always-find-files-when-using-DESTDIR.patch
       COMMAND  ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Do-not-create-symlinks.patch


    CONFIGURE_ARGS --prefix=${EXTPREFIX}
        -Ddoc=disabled
        -Dcache-build=disabled
        -Dtests=disabled
        ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_fontconfig)
