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

set(FFMPEG_GIT_SHA1 1834eb471506fe3f6296aa844825ac317e51bd5b)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_ffmpeg
    MESON
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg.git

    # we use this branch as a source:
    # https://gitlab.freedesktop.org/gstreamer/meson-ports/ffmpeg/-/tree/meson-7.1
    GIT_TAG ${FFMPEG_GIT_SHA1}

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-an-option-to-disable-UB-in-av_uninit.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Add-options-for-SSP-and-CFGuard.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Be-more-forceful-when-setting-PIC-on-x86_32.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-Fix-detection-of-autodetected-libs-when-explicitly-p.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0005-Declare-other-auto-detected-lifraries-as-auto-fieatu.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0006-Fix-building-when-iconv-feature-is-explicitly-disabl.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0007-Switch-deps-of-QSV-codecs-to-libvpl-instead-of-libmf.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0008-Fix-include-paths-for-libavcodec-s-codecs.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0009-Fix-VP9-hw-accelerated-encoder-with-libvpl.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0010-Fix-version-file-generation-in-version.py.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/remove-va.patch
          COMMAND ${CMAKE_COMMAND} -E echo "8.0.1-g${FFMPEG_GIT_SHA1}" > VERSION

    CONFIGURE_ARGS --prefix=${EXTPREFIX}
            -Dvaapi=disabled
            --libdir=lib
            -Dno_uninit_ub=true
            ${_stack_guard_flag}
            -Denable-cfguard=disabled # TODO: change to 'auto' when Krita enabled cfguard internally
            -Dbuildtype=$<IF:$<CONFIG:Debug>,debug,debugoptimized>
            -Ddefault_library=shared
            ${DISABLE_ASM_ON_ANDROID_x86_32}
            -Dprograms=enabled
            -Dtests=disabled
            -Dffmpeg=enabled
            -Dffprobe=enabled
            -Dffplay=disabled
            -Davdevice=disabled
            -Davcodec=enabled
            -Davformat=enabled
            -Davutil=enabled
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
            -Dlibvpl=auto # Intel-specific optimizations
            -Dlibvpx=enabled
            -Dlibvpx_vp9_encoder=enabled
            -Dlibvpx_vp8_encoder=enabled
            -Dlibopenh264=enabled
            -Dlibtheora=enabled
            # ===================== Audio Codecs
            -Dflac_encoder=enabled
            -Daac_encoder=enabled
            -Dlibmp3lame=enabled
            -Dlibopus=enabled
            -Dlibvorbis=enabled
-Dvaapi=disabled
-Dvaapi_drm=disabled
-Dvaapi_x11=disabled
-Dvaapi_win32=disabled
-Dav1_vaapi_encoder=disabled
-Dh264_vaapi_encoder=disabled
-Dhevc_vaapi_encoder=disabled
-Dmjpeg_vaapi_encoder=disabled
-Dmpeg2_vaapi_encoder=disabled
-Dvp8_vaapi_encoder=disabled
-Dvp9_vaapi_encoder=disabled
-Dav1_vaapi_hwaccel=disabled
-Dh263_vaapi_hwaccel=disabled
-Dh264_vaapi_hwaccel=disabled
-Dhevc_vaapi_hwaccel=disabled
-Dmjpeg_vaapi_hwaccel=disabled
-Dmpeg2_vaapi_hwaccel=disabled
-Dmpeg4_vaapi_hwaccel=disabled
-Dvc1_vaapi_hwaccel=disabled
-Dvp8_vaapi_hwaccel=disabled
-Dvp9_vaapi_hwaccel=disabled
-Dvvc_vaapi_hwaccel=disabled
-Dwmv3_vaapi_hwaccel=disabled
-Ddeinterlace_vaapi_filter=disabled
-Ddenoise_vaapi_filter=disabled
-Doverlay_vaapi_filter=disabled
-Dprocamp_vaapi_filter=disabled
-Dscale_vaapi_filter=disabled
-Dsharpness_vaapi_filter=disabled
-Dtonemap_vaapi_filter=disabled
-Dtranspose_vaapi_filter=disabled
-Dhstack_vaapi_filter=disabled
-Dvstack_vaapi_filter=disabled
-Dxstack_vaapi_filter=disabled
-Dpad_vaapi_filter=disabled
-Ddrawbox_vaapi_filter=disabled

            ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_ffmpeg)
