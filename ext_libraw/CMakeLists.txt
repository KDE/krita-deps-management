cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libraw)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if(APPLE)
    # There is no OPENMP support on apple's clang
    set(LIBRAW_CMAKE_FLAGS "-DENABLE_OPENMP=OFF")
endif()

ExternalProject_Add(ext_libraw
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://www.libraw.org/data/LibRaw-0.20.2.tar.gz
    URL_HASH SHA256=dc1b486c2003435733043e4e05273477326e51c3ea554c6864a4eafaff1004a6

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-LibRaw-cmake.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Use-CMake-install-prefix.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${LIBRAW_CMAKE_FLAGS} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libraw)
