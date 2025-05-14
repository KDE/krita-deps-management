cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_nasm)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (WIN32)
    ExternalProject_Add(
        ext_nasm
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

        # the official website seems to be down regularly, please copy the
        # archive to the KDE's infrastructure during updates
        # URL https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-win64.zip

        URL https://files.kde.org/krita/build/dependencies/nasm-2.15.05-win64.zip
        URL_HASH SHA256=f5c93c146f52b4f1664fa3ce6579f961a910e869ab0dae431bd871bdd2584ef2

        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo Deploying nasm 64-bit binaries
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/rdoff -DDST=${EXTPREFIX}/bin/rdoff -P ${KRITA_CI_INSTALL_DIRECTORY}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/nasm.exe -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/ndisasm.exe -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}

        UPDATE_COMMAND ""
    )
else ()
    ExternalProject_Add(
        ext_nasm
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

        # the official website seems to be down regularly, please copy the
        # archive to the KDE's infrastructure during updates
        #URL https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz

        URL https://files.kde.org/krita/build/dependencies/nasm-2.15.05.tar.gz
        URL_HASH SHA256=9182a118244b058651c576baa9d0366ee05983c4d4ae1d9ddd3236a9f2304997

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Disable-installing-man-pages-which-are-not-built.patch

        CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE}

        UPDATE_COMMAND ""
        
        # automake has an issue when tryin gto build outside of the course tree
        # 'sh: 0: Can't open autogen.sh'
        BUILD_IN_SOURCE ON
    )
endif()

krita_add_to_ci_targets(ext_nasm)