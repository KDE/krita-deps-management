cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_quazip)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

##
## WARNING: quazip project lost its maintainer after 2022! Please manually review
##          all the incoming commits when updating version!
##
##          The last version of quazip released with the old maintainer was
##          quazip-v1.4
##

ExternalProject_Add( ext_quazip
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME quazip-v1.4.tar.gz
    URL https://github.com/stachenov/quazip/archive/refs/tags/v1.4.tar.gz
    URL_HASH SHA256=79633fd3a18e2d11a7d5c40c4c79c1786ba0c74b59ad752e8429746fe1781dd6

    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DQUAZIP_BZIP2=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_quazip)
