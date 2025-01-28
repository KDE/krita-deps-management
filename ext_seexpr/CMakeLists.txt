cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_seexpr)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_seexpr
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/kseexpr/4.0.4/kseexpr-4.0.4.0.tar.gz
    URL_MD5 207a7f20fe8995cb0ae90424495a1c67

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DFLAVOR=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DENABLE_LLVM_BACKEND=OFF -DBUILD_DOC=OFF -DBUILD_TESTS=OFF -DBUILD_UTILS=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_seexpr)
