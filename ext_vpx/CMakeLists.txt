cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_vpx)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

if (ANDROID AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
    set (EXTRA_VPX_ANDROID_FLAGS -Dmultithread=disabled)
endif()

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_vpx
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/dimula73/libvpx.git
    GIT_TAG meson

    WORKING_DIRECTORY <BINARY_DIR>

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Ddefault_library=shared
            -Dunit_tests=disabled
            -Dtools=disabled
            -Ddocs=disabled
            ${EXTRA_MESON_FLAGS}
            ${EXTRA_VPX_ANDROID_FLAGS}

    UPDATE_COMMAND ""
)


krita_add_to_ci_targets(ext_vpx)
