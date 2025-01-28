cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libtheora)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

ExternalProject_Add(
    ext_libtheora_meson
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://wrapdb.mesonbuild.com/v2/theora_1.1.1-4/get_patch
    URL_HASH SHA256=210af99fbc5a1b34d0f32270c25ecfb6fae7e76c1ae9dc6971b063317c97a826

    DOWNLOAD_NAME "theora_1.1.1-4_patch.zip"

    BUILD_COMMAND ""
    CONFIGURE_COMMAND ""
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""

    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/theora_meson"
)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_libtheora
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://gitlab.xiph.org/xiph/theora.git
    # gitlab-ci: Add scons build. Latest commit as of Nov 26, 2022
    GIT_TAG 7180717276af1ebc7da15c83162d6c5d6203aabf

    PATCH_COMMAND ${CMAKE_COMMAND} -E echo Deploying Meson wrap
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            ${CMAKE_CURRENT_BINARY_DIR}/theora_meson
            <SOURCE_DIR>
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0010-theora-Update-to-1.2.0.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0011-theora-Add-Arm-support.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-libtheora-Fix-build-on-android-x86.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
        -Ddoc=disabled
        -Dspec=disabled
        ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""

    DEPENDS ext_libtheora_meson
)

krita_add_to_ci_targets(ext_libtheora)
