cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kcoreaddons)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kcoreaddons
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kcoreaddons-6.25.0.tar.xz
    URL_HASH SHA256=e7f0825576dc44af0c7194538e48114aa240f8fd3402f27047771f009e161a7e

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kcoreaddons)
