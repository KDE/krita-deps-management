cmake_minimum_required(VERSION 3.29)

project(ext_gperf)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_gperf
    MESON
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    GIT_REPOSITORY https://gitlab.freedesktop.org/tpm/gperf.git
    GIT_TAG meson

    CONFIGURE_ARGS --prefix=${EXTPREFIX} ${EXTRA_MESON_FLAGS}
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_gperf)
