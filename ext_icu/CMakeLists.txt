cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_fribidi)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

ExternalProject_Add(
    ext_icu_meson
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://wrapdb.mesonbuild.com/v2/icu_72.1-2/get_patch
    URL_HASH SHA256=60451c5db7a25d2cb0ada6e216ba528fbd39839e80a01cb018c548a0afb2bf83

    DOWNLOAD_NAME "icu_72.1-2_patch.zip"

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
    URL https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-src.tgz
    URL_HASH SHA256=a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68

    PATCH_COMMAND ${CMAKE_COMMAND} -E echo Deploying Meson wrap
        COMMAND ${CMAKE_COMMAND} -E copy_directory 
            ${CMAKE_CURRENT_BINARY_DIR}/meson
            <SOURCE_DIR>
        COMMAND ${CMAKE_COMMAND} -E echo Deploying patches
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-MinGW-support-from-MSYS.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Windows-enable-C-code-generation-with-overridden-ent.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-toolutil-Fix-crash-when-trying-to-generate-MinGW-ass.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0005-toolutil-Fix-MASM-generation-for-x86-64-and-ARM64.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0006-toolutil-Add-NASM-generator.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0007-meson-Use-NASM-to-work-around-MSVC-compiler-performa.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0008-meson-Work-around-Meson-linking-bug-when-there-s-no-.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0009-meson-Enable-icudata-for-MSVC.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0010-meson-Work-around-windeployqt-expecting-no-ICU-prefi.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX} ${EXTRA_MESON_FLAGS}
    UPDATE_COMMAND ""

    DEPENDS ext_icu_meson
)

krita_add_to_ci_targets(ext_icu)