cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_xsimd)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_xsimd
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

#    Update to xsimd 11.1.0 after releasing Krita 5.2.0
#    URL https://github.com/xtensor-stack/xsimd/archive/refs/tags/11.1.0.tar.gz
#    URL_HASH SHA256=aa54dba8daade472656eba0d27154f072fec06ee3831aefcac69a5f6c7dbbae7

    URL https://github.com/xtensor-stack/xsimd/archive/5647254635ea6f590b7366e0848a8a0ab3007efa.tar.gz
    URL_HASH SHA256=5b175c8b671d4287343b0e79e9e3a8070992815f5e0ed44bfc9bce01f8880814

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_xsimd)
