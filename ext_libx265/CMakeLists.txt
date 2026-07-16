cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libx265)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

include(${CMAKE_SOURCE_DIR}/../ext_libx265/x265_shared_patches.cmake)
if (NOT X265_SHARED_PATCH_COMMAND)
    message(FATAL_ERROR "Failed to fetch the patches list")
endif()

# Incorporate Handbrake's extensions for building x265
# Multicoreware added detection of SSE2/3/4.1, so we can freely enable them now
# Also ship their patch for Apple silicon
if (MSVC)
    # set(x265_LIBDIR "$<CONFIG>/")
    # set(x265_LIBRARY x265-static.lib)
    set(x265_10bit_LIBRARY x265_main10-static.lib)
    set(x265_12bit_LIBRARY x265_main12-static.lib)
    set(x265_EXTRA_LINK_FLAGS /LIBPATH:${EXTPREFIX}/lib)
else()
    # set(x265_LIBDIR "")
    # set(x265_LIBRARY libx265.a)
    set(x265_10bit_LIBRARY libx265_main10.a)
    set(x265_12bit_LIBRARY libx265_main12.a)
    set(x265_EXTRA_LINK_FLAGS -L${EXTPREFIX}/lib)
endif()
ExternalProject_Add(
    ext_libx265
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/HandBrake/HandBrake-contribs/releases/download/contribs2/x265-snapshot-20260216-13309.tar.gz
    URL_HASH SHA256=a0882bb90826da62a96676c1a7cb7a7beb7f1db901f2775299cbeed03c3eb2a2

    SOURCE_SUBDIR source/

    ${X265_SHARED_PATCH_COMMAND}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DENABLE_SHARED=TRUE  -DENABLE_HDR10_PLUS=TRUE -DEXTRA_LIB:String=${x265_10bit_LIBRARY}$<SEMICOLON>${x265_12bit_LIBRARY} -DEXTRA_LINK_FLAGS:String=${x265_EXTRA_LINK_FLAGS} -DLINKED_10BIT=TRUE -DLINKED_12BIT=TRUE

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libx265)
