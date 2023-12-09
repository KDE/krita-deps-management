#
# From https://github.com/ampl/gsl. which adds CMake support to gsl
#

cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_gsl)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (UNIX)
ExternalProject_Add( ext_gsl

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/ampl/gsl/archive/8eac3b0b5cffb90004a729f0675011e718f41379.zip
    URL_HASH SHA256=124bf79bfd2c3cb07df02a2b0e80e13d29a94cab8acae1c2c1e086474381a6c2

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/gsl-android.patch
                COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/gsl-2.3_clang12.patch
    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DNO_AMPL_BINDINGS=ON
    UPDATE_COMMAND ""
)
else()
ExternalProject_Add( ext_gsl

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/ampl/gsl/archive/8eac3b0b5cffb90004a729f0675011e718f41379.zip
    URL_HASH SHA256=124bf79bfd2c3cb07df02a2b0e80e13d29a94cab8acae1c2c1e086474381a6c2

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/windows-no-fPIC.patch

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTING=OFF -DNO_AMPL_BINDINGS=ON
    UPDATE_COMMAND ""
)

endif()

krita_add_to_ci_targets(ext_gsl)
