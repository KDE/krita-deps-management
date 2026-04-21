cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_immer)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_immer
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/arximboldi/immer/archive/refs/tags/v0.9.1.tar.gz
    URL_HASH SHA256=b18b92ba60ec3186dc36ef671d3c2ae542cbb63eb6dc0e258476c6111a67c971

    CMAKE_ARGS -Dimmer_BUILD_TESTS=OFF -Dimmer_BUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_immer)
