cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_mlt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (WIN32)
  set(WIN32_CMAKE_ARGS -DWINDOWS_DEPLOY=OFF)
endif()

if (ANDROID)
  set(BUILD_EXTRA_OPTS -DMOD_RTAUDIO=OFF)
else()
  set(BUILD_EXTRA_OPTS)
endif()

kis_ExternalProject_Add_with_separate_builds_apple(
  ext_mlt
  DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
  URL https://github.com/mltframework/mlt/releases/download/v7.22.0/mlt-7.22.0.tar.gz
  URL_HASH MD5=9f747ae1b7388937be6328b4c234431b
  #GIT_REPOSITORY https://github.com/emmetoneillpdx/mlt.git
  #GIT_TAG origin/master

  PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-compilation-on-Windows-with-Clang-15-965.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-macOS-allow-finding-plugins-outside-bundles.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-MLT-check-pointers-before-dereferencing.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-installing-melt-manpage-when-DESTDIR-is-active.patch

  CMAKE_ARGS ${GLOBAL_PROFILE} -DMOD_OPENCV=OFF -DMOD_QT=OFF -DMOD_QT6=OFF ${WIN32_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${BUILD_EXTRA_OPTS}
  UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_mlt)
