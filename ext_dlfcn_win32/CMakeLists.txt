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
    DOWNLOAD_NAME dlfcn_win32-v1.4.2.zip
    URL https://github.com/dlfcn-win32/dlfcn-win32/archive/refs/tags/v1.4.2.zip
    URL_HASH SHA256=7c85998ee4296303bde30e8e9c72c28e637b881e2211682915b53455a65a0d07

    CMAKE_ARGS ${GLOBAL_PROFILE} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
  )
endif()

krita_add_to_ci_targets(ext_dlfcn_win32)
