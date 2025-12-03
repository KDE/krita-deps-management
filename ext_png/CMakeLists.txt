cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_png)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_png
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://downloads.sourceforge.net/project/libpng/libpng16/1.6.51/libpng-1.6.51.tar.xz
    URL_HASH SHA256=a050a892d3b4a7bb010c3a95c7301e49656d72a64f1fc709a90b8aded192bed2

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DPNG_TESTS=OFF

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-naming-of-a-symlink-for-libpng.dll.a.patch

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_png)
