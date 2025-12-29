cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libx265_12bit)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

# Incorporate Handbrake's extensions for building x265
# Multicoreware added detection of SSE2/3/4.1, so we can freely enable them now
# Also ship their patch for Apple silicon
if (MSVC)
    set(x265_LIBDIR "$<CONFIG>/")
    set(x265_LIBRARY x265-static.lib)
    # set(x265_10bit_LIBRARY x265_main10-static.lib)
    set(x265_12bit_LIBRARY x265_main12-static.lib)
    # set(x265_EXTRA_LINK_FLAGS /LIBPATH:${EXTPREFIX}/lib)
else()
    set(x265_LIBDIR "")
    set(x265_LIBRARY libx265.a)
    # set(x265_10bit_LIBRARY libx265_main10.a)
    set(x265_12bit_LIBRARY libx265_main12.a)
    # set(x265_EXTRA_LINK_FLAGS -L${EXTPREFIX}/lib)
endif()
ExternalProject_Add(ext_libx265_12bit
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/HandBrake/HandBrake-contribs/releases/download/contribs2/x265-snapshot-20250729-13276.tar.gz
    URL_HASH SHA256=3feb40d5f7fc37aba193a686a4445efff332f18d0f4830c6af565c3e18d340a8

    SOURCE_SUBDIR source/

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A01-Do-not-set-thread-priority-on-Windows.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A02-Apple-Silicon-tuning.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A03-Implement-ambient-viewing-environment-sei.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A04-add-new-matrix-coefficients-from-H.273-v3.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A05-Fix-Dolby-Vision-RPU-memory-management.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A06-Update-version-strings.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A07-Fix-macOS-cross-compilation.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A08-Fix-inconsistent-bitrate-in-second-pass.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A09-Ensuring-the-mvdLX-is-compliant.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/handbrake/A10-AArch64-Fix-scanPosLast_neon-compilation-with-old-bi.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/0001-ext_heif-Make-sure-that-pthreads-are-not-linked-it-o.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/../ext_libx265/patches/0002-Skip-PDB-in-MinGW.patch


    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} 
    -DHIGH_BIT_DEPTH=TRUE -DMAIN12=TRUE -DEXPORT_C_API=FALSE  -DENABLE_CLI=FALSE -DENABLE_SHARED=FALSE
    INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=${x265_LIBDIR}${x265_LIBRARY} -DDST=${EXTPREFIX}/lib -DRENAME=${x265_12bit_LIBRARY} -P  ${KRITA_CI_INSTALL}
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libx265_12bit)
