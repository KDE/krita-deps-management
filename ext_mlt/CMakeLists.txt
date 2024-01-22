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
  GIT_REPOSITORY https://github.com/Eoin-ONeill-Yokai/mlt.git
  GIT_TAG 1924f3712e3dc0f7a1e5a1aa658dbbbf0e863754
  PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-macOS-allow-finding-plugins-outside-bundles.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-MLT-check-pointers-before-dereferencing.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-producer_krita-to-stop-at-the-end-of-the-stream.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-installing-melt-manpage-when-DESTDIR-is-active.patch

  CMAKE_ARGS ${GLOBAL_PROFILE} -DMOD_OPENCV=OFF -DMOD_QT=OFF -DMOD_QT6=OFF ${WIN32_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${BUILD_EXTRA_OPTS}
  UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_mlt)
