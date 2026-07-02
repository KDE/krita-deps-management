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
    DOWNLOAD_NAME gsl-fb0cfbc82b5e9e4d22444efce9241924f4aefb83.zip
    URL https://github.com/ampl/gsl/archive/fb0cfbc82b5e9e4d22444efce9241924f4aefb83.zip
    URL_HASH SHA256=516d8b529c6ba89d6937b32161d11d66a34b84dbf8cafdb628425731c1a5048e

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/gsl-2.3_clang12.patch
    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DNO_AMPL_BINDINGS=ON
    UPDATE_COMMAND ""
)
else()
ExternalProject_Add( ext_gsl

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME gsl-fb0cfbc82b5e9e4d22444efce9241924f4aefb83.zip
    URL https://github.com/ampl/gsl/archive/fb0cfbc82b5e9e4d22444efce9241924f4aefb83.zip
    URL_HASH SHA256=516d8b529c6ba89d6937b32161d11d66a34b84dbf8cafdb628425731c1a5048e

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_TESTING=OFF -DNO_AMPL_BINDINGS=ON
    UPDATE_COMMAND ""
)

endif()

krita_add_to_ci_targets(ext_gsl)
