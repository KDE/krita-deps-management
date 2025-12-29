cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openjpeg)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_openjpeg
	DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME openjpeg-v2.5.4.tar.gz
    URL https://github.com/uclouvain/openjpeg/archive/v2.5.4.tar.gz
    URL_HASH SHA256=a695fbe19c0165f295a8531b1e4e855cd94d0875d2f88ec4b61080677e27188a

    INSTALL_DIR ${EXTPREFIX}
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DOPENJPEG_INSTALL_INCLUDE_DIR=include/ -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_PKGCONFIG_FILES=ON ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_openjpeg)
