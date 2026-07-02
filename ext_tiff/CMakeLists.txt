cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_tiff)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if(ANDROID)
    # WARNING: this patch should **not** be applied on other platforms,
    # especially on Windows, because it removes a windows specific symbol
    # from the linker script
    set(ANDROID_PATCH_COMMAND
        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-android-Remove-windows-specifc-symbols-from-linker-s.patch)
else()
    set(ANDROID_PATCH_COMMAND)
endif()

ExternalProject_Add( ext_tiff
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.osgeo.org/libtiff/tiff-4.7.1.tar.gz
    URL_HASH SHA256=f698d94f3103da8ca7438d84e0344e453fe0ba3b7486e04c5bf7a9a3fabe9b69

    ${ANDROID_PATCH_COMMAND}
    
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_tiff)
