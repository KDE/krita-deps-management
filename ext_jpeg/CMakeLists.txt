cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_jpeg)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)


if (ANDROID)
    ExternalProject_Add( ext_jpeg
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://downloads.sourceforge.net/project/libjpeg-turbo/2.1.4/libjpeg-turbo-2.1.4.tar.gz
        URL_HASH SHA256=d3ed26a1131a13686dfca4935e520eb7c90ae76fbc45d98bb50a8dc86230342b

        CMAKE_ARGS -DANDROID_ARM_MODE=arm -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DENABLE_SHARED=ON -DWITH_SIMD=OFF -DENABLE_STATIC=OFF _DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
    )
else()
    kis_ExternalProject_Add_with_separate_builds_apple(
        ext_jpeg
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://downloads.sourceforge.net/project/libjpeg-turbo/2.1.4/libjpeg-turbo-2.1.4.tar.gz
        URL_HASH SHA256=d3ed26a1131a13686dfca4935e520eb7c90ae76fbc45d98bb50a8dc86230342b

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DWITH_SIMD=OFF -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}
    )
endif()

krita_add_to_ci_targets(ext_jpeg)