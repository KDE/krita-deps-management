cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_webp)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_webp
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.6.0.tar.gz
    URL_HASH SHA256=e4ab7009bf0629fd11982d4c2aa83964cf244cffba7347ecd39019a9e38c4564

    PATCH_COMMAND  ${PATCH_COMMAND}  -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0007-fix-arm-build.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0008-sdl.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_SHARED_LIBS=ON -DWEBP_BUILD_CWEBP=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_webp)
