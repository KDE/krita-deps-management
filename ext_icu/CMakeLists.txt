cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_icu)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

ExternalProject_Add(
    ext_icu_meson
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://wrapdb.mesonbuild.com/v2/icu_78.2-1/get_patch
    URL_HASH SHA256=a21033c878bf6f09a11888038add7cc070ed6d7e146fc6b4061b547722fc7925

    DOWNLOAD_NAME "icu_78.2-1_patch.zip"

    BUILD_COMMAND ""
    CONFIGURE_COMMAND ""
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""

    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/meson"
)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_icu
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/unicode-org/icu/releases/download/release-78.2/icu4c-78.2-sources.tgz
    URL_HASH SHA256=3e99687b5c435d4b209630e2d2ebb79906c984685e78635078b672e03c89df35

    PATCH_COMMAND ${CMAKE_COMMAND} -E echo Deploying Meson wrap
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            ${CMAKE_CURRENT_BINARY_DIR}/meson
            <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E echo Deploying patches
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-meson-Work-around-windeployqt-expecting-no-ICU-prefi.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX} ${EXTRA_MESON_FLAGS}
    UPDATE_COMMAND ""

    DEPENDS ext_icu_meson
)

krita_add_to_ci_targets(ext_icu)
