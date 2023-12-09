cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_openjpeg)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_openjpeg
	DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/uclouvain/openjpeg/archive/v2.5.0.tar.gz
    URL_HASH SHA256=0333806d6adecc6f7a91243b2b839ff4d2053823634d4f6ed7a59bc87409122a

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Build-fix-linking-of-executables-on-some-systems-whe.patch

    INSTALL_DIR ${EXTPREFIX}
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DOPENJPEG_INSTALL_INCLUDE_DIR=include/ -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_PKGCONFIG_FILES=ON ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_openjpeg)
