cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_poppler)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add( ext_poppler
	DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://poppler.freedesktop.org/poppler-22.08.0.tar.xz
    URL_HASH SHA256=b493328721402f25cb7523f9cdc2f7d7c59f45ad999bde75c63c90604db0f20b

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-fix_sed_invocation.patch
            COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-macos-add-missing-system-header.patch

	INSTALL_DIR ${EXTPREFIX}
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DBUILD_GTK_TESTS=OFF -DBUILD_QT5_TESTS=FALSE -DBUILD_CPP_TESTS=FALSE  -DENABLE_UTILS=FALSE -DENABLE_GLIB=FALSE -DENABLE_LIBOPENJPEG=none -DWITH_NSS3=OFF -DBUILD_MANUAL_TESTS=OFF

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_poppler)
