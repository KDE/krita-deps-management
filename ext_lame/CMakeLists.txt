cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lame)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

ExternalProject_Add(
    ext_lame_meson
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://wrapdb.mesonbuild.com/v2/lame_3.100-9/get_patch
    URL_HASH SHA256=bedda639a621b2046fb04110a51870d6c9640f2f4282b5d877bc452e9943c22e

    DOWNLOAD_NAME "lame_3.100-9_patch.zip"

    BUILD_COMMAND ""
    CONFIGURE_COMMAND ""
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""

    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/lame_meson"
)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_lame
    MESON

    URL https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
    URL_HASH SHA256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e

    PATCH_COMMAND ${CMAKE_COMMAND} -E echo Deploying Meson wrap
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            ${CMAKE_CURRENT_BINARY_DIR}/lame_meson
            <SOURCE_DIR>
        COMMAND ${CMAKE_COMMAND} -E echo Deploying patches
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-lame-Install-pkg-config-file.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            ${EXTRA_MESON_FLAGS}
    
    DEPENDS ext_lame_meson
)

krita_add_to_ci_targets(ext_lame)
