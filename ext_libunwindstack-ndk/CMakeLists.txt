cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_libunwindstack-ndk)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_libunwindstack-ndk
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    SOURCE_SUBDIR ./cmake
    GIT_REPOSITORY https://github.com/getsentry/libunwindstack-ndk.git
    GIT_TAG a4c27d48deff95fe922fe9733ef5c1339bdbf4fb
    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-install-property-and-cmake-config-file.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
               -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
                ${GLOBAL_PROFILE}
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_libunwindstack-ndk)
