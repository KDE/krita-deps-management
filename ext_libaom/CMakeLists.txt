cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libaom)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (NOT WIN32)
    set (LIBAOM_EXTRA_CMAKE_ARGS -DCONFIG_PIC=1)
endif()

set (EXTRA_PERL_ARGS)
if (WIN32)
    # we store our patch perl separately in Krita
    if (EXISTS ${EXTPREFIX}/Strawberry/perl/bin/perl.exe)
        set(EXTRA_PERL_ARGS -DPERL_EXECUTABLE=${EXTPREFIX}/Strawberry/perl/bin/perl.exe)
    endif()
endif()

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_libaom
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL https://storage.googleapis.com/aom-releases/libaom-3.6.1.tar.gz
    URL_HASH SHA256=42b862f58b3d00bd3902d2dc469526574f5b012e5b178e6a9652845a113d6887

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-cdef-Disable-MSVC-optimizations-for-filter_block.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/android-cpu-features.patch

    # Static library is needed because ffmpeg accesses aom_codec_av1_dx_algo
    # which is not exported in Windows compilers.
    #
    # All boolean libaom-specific 'CONFIG_*' options should have value 0 or 1, because
    # they are passed straight to asm files. We cannot use CMake's ON/OFF for them
    CMAKE_ARGS ${LIBAOM_EXTRA_CMAKE_ARGS} ${EXTRA_PERL_ARGS} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_SHARED_LIBS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_TESTDATA=OFF -DENABLE_TESTS=OFF -DENABLE_TOOLS=OFF ${GLOBAL_PROFILE} -DCONFIG_RUNTIME_CPU_DETECT=1

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libaom)
