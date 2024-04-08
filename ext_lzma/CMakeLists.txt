cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lzma)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

##
# Be careful when updating LZMA:
# Versions 5.6.0 and 5.6.1 are backdored (CVE-2024-3094)
##

if (WIN32)
    ExternalProject_Add( ext_lzma
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://tukaani.org/xz/xz-5.2.6-windows.zip
        URL_HASH SHA256=6fd6dad79e5b0d3b24a43bc3f79472b62a48d210f1aaa02fb06e5dfad89a4ebc

        INSTALL_DIR ${EXTPREFIX}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying 64-bit liblzma.dll
        INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin_x86-64/liblzma.dll -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin_x86-64/liblzma.a -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include/lzma.h -DDST=${EXTPREFIX}/include/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include/lzma -DDST=${EXTPREFIX}/include/lzma/ -P ${KRITA_CI_INSTALL_DIRECTORY}

        UPDATE_COMMAND ""
    )
else ()
    ExternalProject_Add( ext_lzma
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://tukaani.org/xz/xz-5.2.6.tar.gz
        URL_HASH SHA256=a2105abee17bcd2ebd15ced31b4f5eda6e17efd6b10f921a01cda4a44c91b3a0

        INSTALL_DIR ${EXTPREFIX}
        CONFIGURE_COMMAND ./configure --prefix=${EXTPREFIX} --disable-xz --disable-xzdec --disable-lzmadec --disable-lzmainfo --disable-lzma-links --disable-scripts --disable-doc --disable-static --enable-shared ${GLOBAL_AUTOMAKE_PROFILE}

        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 1
    )

endif ()

krita_add_to_ci_targets(ext_lzma)
