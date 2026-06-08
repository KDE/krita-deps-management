cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_gettext)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (WIN32)
    ExternalProject_Add(ext_gettext_bin

        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.21-v1.16/gettext0.21-iconv1.16-static-64.zip
        URL_HASH SHA256=721395c2e057eeed321f0c793311732e57cb4fa30d5708672a13902a69a77d43

        BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying gettext 64-bit dependencies
        CONFIGURE_COMMAND ""

        INSTALL_COMMAND COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${EXTPREFIX} -P ${KRITA_CI_INSTALL_DIRECTORY}

        UPDATE_COMMAND ""
    )
    ExternalProject_Add (
        ext_gettext_lib
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.kde.org/krita/build/dependencies/gettext-0.21.tar.xz
        URL_MD5 40996bbaf7d1356d3c22e33a8b255b31

        PATCH_COMMAND ${PATCH_COMMAND} --binary -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-macro-definitions.patch
            COMMAND ${PATCH_COMMAND} --binary -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Fix-uwp-build.patch
            COMMAND ${PATCH_COMMAND} --binary -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Fix-win-unicode-paths.patch
            COMMAND ${PATCH_COMMAND} --binary -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-vcpkg-CMake-toolchain.patch
            COMMAND ${PATCH_COMMAND} --binary -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0005-win-Fix-missing-declarations-from-wchar.h.patch
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}
        UPDATE_COMMAND ""
    )

    krita_add_to_ci_targets(ext_gettext_lib)
    krita_add_to_ci_targets(ext_gettext_bin)

else ()
ExternalProject_Add( ext_gettext
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://files.kde.org/krita/build/dependencies/gettext-0.21.tar.xz
    URL_MD5 40996bbaf7d1356d3c22e33a8b255b31
    PATCH_COMMAND ${PATCH_COMMAND} -Z -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-libgettextpo-linking-on-macOS.patch

    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTPREFIX} --disable-java ${GLOBAL_AUTOMAKE_PROFILE} --disable-native-java 

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_gettext)

endif ()
