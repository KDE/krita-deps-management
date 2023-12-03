cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_png)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_png
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://downloads.sourceforge.net/project/libpng/libpng16/1.6.38/libpng-1.6.38.tar.xz
    URL_HASH SHA256=b3683e8b8111ebf6f1ac004ebb6b0c975cd310ec469d98364388e9cedbfa68be

    INSTALL_DIR ${PREFIX_ext_png}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DPNG_TESTS=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_png)