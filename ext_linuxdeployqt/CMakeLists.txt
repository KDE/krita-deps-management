cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_linuxdeployqt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_linuxdeployqt
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/probonopd/linuxdeployqt.git
    GIT_TAG 5b437841c7cb255b4ead3a91090ca6d7154742a5

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-runtime-file-option-that-passes.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}/appimage-tools -DCMAKE_BUILD_TYPE=Release
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_linuxdeployqt)
