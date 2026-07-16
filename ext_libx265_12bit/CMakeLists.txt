cmake_minimum_required(VERSION 3.29)

project(ext_libx265_12bit)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

include(${CMAKE_SOURCE_DIR}/../ext_libx265/x265_shared_patches.cmake)
if (NOT X265_SHARED_PATCH_COMMAND)
    message(FATAL_ERROR "Failed to fetch the patches list")
endif()

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
    URL https://github.com/HandBrake/HandBrake-contribs/releases/download/contribs2/x265-snapshot-20260216-13309.tar.gz
    URL_HASH SHA256=a0882bb90826da62a96676c1a7cb7a7beb7f1db901f2775299cbeed03c3eb2a2

    SOURCE_SUBDIR source/

    ${X265_SHARED_PATCH_COMMAND}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} 
    -DHIGH_BIT_DEPTH=TRUE -DMAIN12=TRUE -DEXPORT_C_API=FALSE  -DENABLE_CLI=FALSE -DENABLE_SHARED=FALSE
    INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=${x265_LIBDIR}${x265_LIBRARY} -DDST=${EXTPREFIX}/lib -DRENAME=${x265_12bit_LIBRARY} -P  ${KRITA_CI_INSTALL}
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libx265_12bit)
