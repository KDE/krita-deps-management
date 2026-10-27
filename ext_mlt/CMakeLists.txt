cmake_minimum_required(VERSION 3.29)

project(ext_mlt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (WIN32)
  set(WIN32_CMAKE_ARGS -DWINDOWS_DEPLOY=OFF)
endif()

if (ANDROID)
  set(BUILD_EXTRA_OPTS -DMOD_RTAUDIO=OFF)
  set(ANDROID_EXTRA_PATCHES COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0011-android-Fix-export-table-for-FILE-arguments-with-NDK.patch)
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

  # TODO: update actual URL after this patch is merged: https://github.com/mltframework/mlt/pull/1256
  # don't forget GIT_SHALLOW and GIT_SUBMODULES_RECURSE, since MLT has modules
  URL https://github.com/mltframework/mlt/releases/download/v7.38.0/mlt-7.38.0.tar.gz
  URL_HASH SHA256=b8f0a23c89e9250edc5038d745537c382367bf2ad3dad5d5c7cd13b0fe1c4144

  PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-MacOS-allow-finding-plugins-outside-bundles.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-MLT-check-pointers-before-dereferencing.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Fix-installing-melt-manpage-when-DESTDIR-is-active.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-Android-Add-an-option-to-skip-non-plugins-in-reposit.patch
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
    -DMOD_PLUS=ON
    -DMOD_PLUSGPL=OFF
    -DMOD_QT=OFF
    -DMOD_QT6=OFF
    -DMOD_RESAMPLE=OFF
    -DMOD_RNNOISE=OFF
    -DMOD_SOX=OFF
    -DMOD_SPATIALAUDIO=OFF
    -DMOD_VIDSTAB=OFF
    -DMOD_XINE=OFF
    -DMOD_XML=OFF

    -DUSE_AVDEVICE=OFF

    ${WIN32_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${BUILD_EXTRA_OPTS}
  UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_mlt)
