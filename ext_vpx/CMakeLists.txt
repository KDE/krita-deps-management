cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_vpx)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

set (EXTRA_VPX_ANDROID_FLAGS)

if (ANDROID AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
    list (APPEND EXTRA_VPX_ANDROID_FLAGS -Dmultithread=disabled)
endif()

if (ANDROID)
    list (APPEND EXTRA_VPX_ANDROID_FLAGS -Dcpu_features_path=${ANDROID_CPUFEATURES_PATH})
endif()

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_vpx
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/dimula73/libvpx.git
    GIT_TAG meson-2

    WORKING_DIRECTORY <BINARY_DIR>

    # for some reason upstream version disables shared builds on Windows,
    # I guess it is related to the MSVC support. Since we use clang for
    # our builds, it should be fine just to ignore this check
    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Allow-shared-libraries-everywhere.patch

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
