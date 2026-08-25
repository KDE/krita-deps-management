cmake_minimum_required(VERSION 3.29)

project(ext_libintl-lite)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_libintl-lite
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/j-jorge/libintl-lite.git
    GIT_TAG edbb3064b2ee7ed42ffc5a4b9e0b8c3616d54cbf

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
               -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
               -DBUILD_TESTING=OFF
                ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libintl-lite)
