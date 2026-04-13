cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kcodecs)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kcodecs
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kcodecs-6.25.0.tar.xz
    URL_HASH SHA256=5051fe783803d94444a231c79635b96f1266594942b836f59ae8460497c788c5

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} 
        -DBUILD_TESTING=OFF
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kcodecs)
