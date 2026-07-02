cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_appimagetool)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set(BOOTSTRAP_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bootstrap_prefix)

ExternalProject_Add( ext_appimagetool-binary
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    # Release https://github.com/AppImage/appimagetool/releases/tag/1.9.1 (4 dec 2025)
    URL https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage
    URL_HASH SHA256=ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0
    DOWNLOAD_NO_EXTRACT TRUE

    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND chmod u+x <DOWNLOADED_FILE>
          COMMAND <DOWNLOADED_FILE> --appimage-extract

    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/squashfs-root/usr/bin ${BOOTSTRAP_PREFIX}/bin

    UPDATE_COMMAND ""
)

ExternalProject_Add( ext_appimagetool-runtime
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64
    URL_HASH SHA256=2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d
    DOWNLOAD_NO_EXTRACT TRUE

    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""

    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${BOOTSTRAP_PREFIX}/share
            COMMAND ${CMAKE_COMMAND} -E copy <DOWNLOADED_FILE> ${BOOTSTRAP_PREFIX}/share

    UPDATE_COMMAND ""
)

add_custom_target(install_bootstrapped_folder
    COMMAND ${CMAKE_COMMAND} -DSRC=${BOOTSTRAP_PREFIX} -DDST=${EXTPREFIX}/appimage-tools -P ${KRITA_CI_INSTALL_DIRECTORY}
    DEPENDS ext_appimagetool-binary ext_appimagetool-runtime
)

if (NOT TARGET ext_build)
    add_custom_target(ext_build)
endif()
add_dependencies(ext_build ext_appimagetool-binary ext_appimagetool-runtime)

if (NOT TARGET ext_install)
    add_custom_target(ext_install)
endif()
add_dependencies(ext_install install_bootstrapped_folder)
