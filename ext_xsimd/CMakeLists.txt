cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_xsimd)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_xsimd
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

#    Update to xsimd 13.0.0 after releasing Krita 5.2.3
#    DOWNLOAD_NAME xsimd-13.0.0.tar.gz
#    URL https://github.com/xtensor-stack/xsimd/archive/refs/tags/13.0.0.tar.gz
#    URL_HASH SHA256=8bdbbad0c3e7afa38d88d0d484d70a1671a1d8aefff03f4223ab2eb6a41110a3
#    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-xsimd13-Fix-detection-of-SSE-AVX-AVX512-when-they-are-explic.patch
#          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-xsimd13-Fix-xsimd-available_architectures-.has-for-sve-and-r.patch
#          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-xsimd13-Poison-XSIMD-s-config-until-the-fix-is-released-upst.patch

    DOWNLOAD_NAME xsimd-5647254635ea6f590b7366e0848a8a0ab3007efa.tar.gz
    URL https://github.com/xtensor-stack/xsimd/archive/5647254635ea6f590b7366e0848a8a0ab3007efa.tar.gz
    URL_HASH SHA256=5b175c8b671d4287343b0e79e9e3a8070992815f5e0ed44bfc9bce01f8880814
    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-detection-of-SSE-AVX-AVX512-when-they-are-explic.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_xsimd)
