cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_flac)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_flac
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    # the official .tar.xz cannot be unpacked by CMake on macOS due to usage
    # of UTF-8 internationalized filenames in
    # test/flac-to-flac-metadata-test-files.
    GIT_REPOSITORY https://github.com/xiph/flac.git
    GIT_TAG 1.4.2

    # Emmet: if you need metaflac, please add:
    # -DIconv_IS_BUILT_IN=TRUE
    # -DBUILD_PROGRAMS=FALSE
    # and add ${ICONV_DEP} to DEPENDS.
    # otherwise CMake's FindIconv gets confused due to libiconv having
    # its headers in the include path

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_SHARED_LIBS=TRUE
        -DBUILD_PROGRAMS=FALSE
        -DBUILD_EXAMPLES=FALSE
        -DBUILD_TESTING=FALSE
        -DBUILD_DOCS=FALSE
        -DINSTALL_MANPAGES=FALSE
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""

    DEPENDS ${OGG_DEP}
)

krita_add_to_ci_targets(ext_flac)
