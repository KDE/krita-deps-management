cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_dlfcn_win32)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (MINGW)
  ExternalProject_Add(
    ext_dlfcn_win32
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v1.3.1.zip
    URL_HASH SHA256=4f611c4372eef7f0179a33f76f84d54857c4fe676b60b654c6c5d91a6d4dad55

    CMAKE_ARGS ${GLOBAL_PROFILE} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
  )
endif()

krita_add_to_ci_targets(ext_dlfcn_win32)
