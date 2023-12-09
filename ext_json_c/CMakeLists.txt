cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_json_c)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_json_c
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/json-c/json-c/archive/refs/tags/json-c-0.16-20220414.tar.gz
    URL_HASH SHA256=3ecaeedffd99a60b1262819f9e60d7d983844073abc74e495cb822b251904185

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DDISABLE_WERROR=ON

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_json_c)
