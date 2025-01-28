cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_json_c)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_json_c
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/json-c/json-c/archive/refs/tags/json-c-0.18-20240915.zip
    URL_HASH SHA256=eb023faa92d2f2f8f7f28e1a4db0322a47363a89d9fed376b997781e1bc7ecce

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DDISABLE_WERROR=ON

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_json_c)
