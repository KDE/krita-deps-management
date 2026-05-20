cmake_minimum_required(VERSION 3.29)

project(ext_linuxdeployqt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_linuxdeployqt
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/probonopd/linuxdeployqt.git
    GIT_TAG 7e7a01d565dde3c5e116c9369026c27a2903bb9d

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-runtime-file-option-that-passes.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Update-to-cmake4.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}/appimage-tools -DCMAKE_BUILD_TYPE=Release
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_linuxdeployqt)
