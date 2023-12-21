cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libheif)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_libheif
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL https://github.com/strukturag/libheif/releases/download/v1.13.0/libheif-1.13.0.tar.gz
    URL_HASH SHA256=c20ae01bace39e89298f6352f1ff4a54b415b33b9743902da798e8a1e51d7ca1

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/clang-aom-link-pthread.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DWITH_EXAMPLES=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libheif)
