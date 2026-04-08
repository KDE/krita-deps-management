cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_expat)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_expat
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/libexpat/libexpat/releases/download/R_2_7_5/expat-2.7.5.tar.xz
    URL_HASH SHA256=1032dfef4ff17f70464827daa28369b20f6584d108bc36f17ab1676e1edd2f91

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DBUILD_tests=OFF -DBUILD_examples=OFF -DBUILD_tools=OFF -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} <SOURCE_DIR>/expat
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_expat)
