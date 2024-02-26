cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_jpegxl)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (MINGW)
    include(CheckCXXSymbolExists)
    include(CheckCXXCompilerFlag)
    check_cxx_symbol_exists(PRIu64 "inttypes.h" CAN_BUILD_HIGHWAY)
    check_cxx_compiler_flag("-mavx512f" CAN_TARGET_AVX512F)
    if (NOT CAN_BUILD_HIGHWAY OR NOT CAN_TARGET_AVX512F)
        message(WARNING "Skipping libjxl, compiler cannot build highway.")
        return()
    endif()
endif()

ExternalProject_Add( ext_jpegxl
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL https://github.com/libjxl/libjxl/archive/refs/tags/v0.10.0.tar.gz
    URL_HASH SHA256=ab32d52b033c814d24762db4942a3b45315d9db37bf5c8a9741ccc1bb0a52d97

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DJPEGXL_VERSION=0.10.0
        -DJPEGXL_ENABLE_BENCHMARK=OFF
        -DJPEGXL_ENABLE_COVERAGE=OFF
        -DJPEGXL_ENABLE_EXAMPLES=OFF
        -DJPEGXL_ENABLE_FUZZERS=OFF
        -DJPEGXL_ENABLE_JNI=OFF
        -DJPEGXL_ENABLE_SJPEG=OFF
        -DJPEGXL_ENABLE_SKCMS=OFF
        -DJPEGXL_ENABLE_TOOLS=OFF
        -DJPEGXL_ENABLE_VIEWERS=OFF
        -DJPEGXL_ENABLE_JPEGLI_LIBJPEG=OFF
        -DJPEGXL_ENABLE_JPEGLI=OFF
        "-DCMAKE_CXX_FLAGS:STRING=-DJXL_DEBUG_ON_ERROR -DJX_DEBUG_WARNING" ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_jpegxl)
