cmake_minimum_required(VERSION 3.29)

project(ext_zug)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_zug
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/arximboldi/zug.git
    GIT_TAG v0.1.2

    CMAKE_ARGS -Dzug_BUILD_TESTS=OFF -Dzug_BUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_zug)
