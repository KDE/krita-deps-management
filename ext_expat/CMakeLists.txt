cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_expat)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_expat
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/libexpat/libexpat/releases/download/R_2_4_8/expat-2.4.8.tar.xz
    URL_HASH SHA256=f79b8f904b749e3e0d20afeadecf8249c55b2e32d4ebb089ae378df479dcaf25

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DBUILD_tests=OFF -DBUILD_examples=OFF -DBUILD_tools=OFF -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} <SOURCE_DIR>/expat
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_expat)
