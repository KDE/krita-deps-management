cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_ffmpeg)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

if (ANDROID AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
    set(DISABLE_ASM_ON_ANDROID_x86_32 "-Dasm=disabled" "-Dinline_asm=disabled")
endif()
# IMPORTANT:
# OpenSUSE's list of whitelisted encoders: https://build.opensuse.org/package/view_file/openSUSE:Factory/ffmpeg-5/enable_encoders
# OpenSUSE's list of whitelisted decoders: https://build.opensuse.org/package/view_file/openSUSE:Factory/ffmpeg-5/enable_decoders
# Above are the lists of codecs that have been approved for use by OpenSUSE's legal department.
# Anything not enabled (missing or commented out) in these lists is considered unsafe and should NOT be used!
# While unlikely, it's possible that these lists could change, so it's worth occasionally cross-referencing.

if (NOT MSVC)
    set(_stack_guard_flag "-Denable-ssp=enabled")
endif() 

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_ffmpeg
    MESON
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg.git

    # we use this branch as a source:
    # https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg/-/tree/meson-4.4
    GIT_TAG c6e46e6e662742531a84b0d99f2772d9a4017c23

    # Workaround https://github.com/mesonbuild/meson/issues/11113
    # See https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg/-/issues/31
    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-ffmpeg-Add-an-option-to-disable-UB-in-av_uninit.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-ffmpeg-Add-options-for-SSP-and-CFGuard.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Disable-ebp_available-on-android.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-libavutil-Don-t-disable-PIC-on-x86_32.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-ffmpeg-Be-more-forceful-when-setting-PIC-on-x86_32.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Copy-over-some-macros-from-libavutil-version.h.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-debugging-for-the-linker.patch

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            --libdir=lib
            -Dno_uninit_ub=true
            ${_stack_guard_flag}
            -Denable-cfguard=disabled # TODO: change to 'auto' when Krita enabled cfguard internally
            -Dbuildtype=$<IF:$<CONFIG:Debug>,debug,debugoptimized>
            -Ddefault_library=shared
            ${DISABLE_ASM_ON_ANDROID_x86_32}
            -Dcli=enabled
            -Dtests=disabled
            -Dffprobe=enabled
            -Dffplay=disabled
            -Davdevice=disabled
            -Davcodec=enabled
            -Davformat=enabled
            -Davutil=enabled
            -Davresample=enabled
            -Dswresample=enabled
            -Dswscale=enabled
            -Dpostproc=disabled
            -Dsdl2=enabled
            -Dlibaom=enabled
            -Dzlib=enabled
            -Dimage2_demuxer=enabled
            -Dimage2_alias_pix_demuxer=enabled
            -Dimage2_brender_pix_demuxer=enabled
            # ===================== Container Formats
            -Dwebm_muxer=enabled
            -Dmatroska_muxer=enabled
            -Dogg_muxer=enabled
            -Dapng_muxer=enabled
            # ===================== Image Formats
            -Dlibwebp=enabled
            -Dpng_encoder=enabled
            -Dpng_decoder=enabled
            -Dapng_encoder=enabled
            -Dapng_decoder=enabled
            # ===================== Video Codecs
            -Dlibaom_av1_encoder=enabled
            -Dlibvpx_vp9_encoder=auto
            -Dlibvpx_vp8_encoder=auto
            -Dlibopenh264=enabled
            -Dlibtheora=enabled
            # ===================== Audio Codecs
            -Dflac_encoder=enabled
            -Daac_encoder=enabled
            -Dlibmp3lame=enabled
            -Dlibopus=enabled
            -Dlibvorbis=enabled
            ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_ffmpeg)
