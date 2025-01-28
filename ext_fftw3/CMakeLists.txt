cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_fftw3)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i?86.*|x86.*|x86_64.*|amd64.*|AMD64.*)")
    set(SSE_OPTIMIZATIONS_STRING "-DENABLE_SSE=ON" "-DENABLE_SSE2=ON")
else()
    set(SSE_OPTIMIZATIONS_STRING "")
endif()

if (WIN32)
    set(THREADING_OPTIONS "-DWITH_COMBINED_THREADS=ON")
else()
    set(THREADING_OPTIONS "-DENABLE_THREADS=ON")
endif()

ExternalProject_Add( ext_fftw3
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://fftw.org/fftw-3.3.10.tar.gz
        URL_HASH SHA256=56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patch_mingw.patch

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} ${SSE_OPTIMIZATIONS_STRING} ${THREADING_OPTIONS} -DBUILD_TESTS=OFF

        UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_fftw3)
