cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_highway)
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

ExternalProject_Add( ext_highway
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/google/highway/archive/refs/tags/1.0.2.tar.gz
    URL_HASH SHA256=e8ef71236ac0d97f12d553ec1ffc5b6375d57b5f0b860c7447dd69b6ed1072db

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF ${GLOBAL_PROFILE} 

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_highway)
