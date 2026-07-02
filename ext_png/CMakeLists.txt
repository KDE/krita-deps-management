cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_png)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_png
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://sourceforge.net/projects/libpng/files/libpng16/1.6.58/libpng-1.6.58.tar.gz
    URL_HASH SHA256=8c9b05b675ca7301a458df2c2e46f26e1d41ff36b8863f8c33530bc58c2e6225

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DPNG_TESTS=OFF

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-naming-of-a-symlink-for-libpng.dll.a.patch

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_png)
