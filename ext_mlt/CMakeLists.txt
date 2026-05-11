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
  set(ANDROID_EXTRA_PATCHES COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0011-android-Fix-export-table-for-FILE-arguments-with-NDK.patch)
  if (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    list(APPEND ANDROID_EXTRA_PATCHES
         COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0012-android-Try-changing-linker-version-specification-to-long-lo.patch)
  endif()
else()
  set(BUILD_EXTRA_OPTS)
  set(ANDROID_EXTRA_PATCHES)
endif()

if (MLT_ENABLE_DEBUG_INFO)
  list(APPEND BUILD_EXTRA_OPTS -DCMAKE_BUILD_TYPE=RelWithDebInfo)
endif()

kis_ExternalProject_Add_with_separate_builds_apple(
  ext_mlt
  DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
  URL https://github.com/mltframework/mlt/releases/download/v7.38.0/mlt-7.38.0.tar.gz
  URL_HASH SHA256=b8f0a23c89e9250edc5038d745537c382367bf2ad3dad5d5c7cd13b0fe1c4144

  PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-MacOS-allow-finding-plugins-outside-bundles.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-MLT-check-pointers-before-dereferencing.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Fix-installing-melt-manpage-when-DESTDIR-is-active.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-Android-Add-an-option-to-skip-non-plugins-in-reposit.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0013-Make-avdevice-library-optional-again.patch
        ${ANDROID_EXTRA_PATCHES}

  CMAKE_ARGS ${GLOBAL_PROFILE}
    -DMOD_SDL2=ON
    -DMOD_VORBIS=ON

    # TODO: do we need this module?
    -DMOD_NORMALIZE=OFF
    # TODO: we might want to enable this module, we need speed stretching
    -DMOD_RUBBERBAND=OFF
    # TODO: do we need this module?
    -DMOD_RTAUDIO=OFF

    -DMOD_DECKLINK=OFF
    -DMOD_FREI0R=OFF
    -DMOD_GDK=OFF
    -DMOD_JACKRACK=OFF
    -DUSE_LV2=OFF
    -DUSE_VST2=OFF
    -DMOD_KDENLIVE=OFF
    -DMOD_MOVIT=OFF
    -DMOD_OLDFILM=OFF
    -DMOD_OPENCV=OFF
    -DMOD_OPENFX=OFF
    -DMOD_PLUS=OFF
    -DMOD_PLUSGPL=OFF
    -DMOD_QT=OFF
    -DMOD_QT6=OFF
    -DMOD_RESAMPLE=OFF
    -DMOD_SOX=OFF
    -DMOD_SPATIALAUDIO=OFF
    -DMOD_VIDSTAB=OFF
    -DMOD_XINE=OFF
    -DMOD_XML=OFF

    ${WIN32_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${BUILD_EXTRA_OPTS}
  UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_mlt)
