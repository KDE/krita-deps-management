cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_zlib)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (NOT APPLE)
ExternalProject_Add(
    ext_zlib
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.gz
    URL_HASH SHA256=bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Prevent-invalid-inclusions-when-HAVE_-is-set-to-0.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

# ZLib had a naming bug on Windows for ages, it is resolved in newer versions:
# https://github.com/madler/zlib/issues/652

else()
ExternalProject_Add(
    ext_zlib
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.gz
    URL_HASH SHA256=bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)
endif()

krita_add_to_ci_targets(ext_zlib)
