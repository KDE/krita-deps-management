cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libogg)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)


ExternalProject_Add(
    ext_libogg
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL http://downloads.xiph.org/releases/ogg/libogg-1.3.6.tar.gz
    URL_HASH SHA256=83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-libogg-Fix-library-filename-on-Windows.patch

    CMAKE_ARGS -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libogg)
