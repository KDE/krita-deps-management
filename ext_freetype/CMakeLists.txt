cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_freetype)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

if (POLICY CMP0114)
    cmake_policy(SET CMP0114 NEW)
endif()

set(FREETYPE_URL https://downloads.sourceforge.net/project/freetype/freetype2/2.12.1/freetype-2.12.1.tar.xz)
set(FREETYPE_SHA256 4766f20157cc4cf0cd292f80bf917f92d1c439b243ac3018debf6b9140c41a7f)

set(BOOTSTRAP_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/bootstrap_prefix)

ExternalProject_Add(ext_freetype_bootstrap
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

    URL ${FREETYPE_URL}
    URL_HASH SHA256=${FREETYPE_SHA256}

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-freetype-Fix-pkgconfig-files-to-be-relocatable.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${BOOTSTRAP_PREFIX}
        -DFT_DISABLE_BZIP2=ON
        -DFT_DISABLE_BROTLI=ON
        -DFT_REQUIRE_PNG=ON
        -DFT_DISABLE_HARFBUZZ=ON
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DBUILD_SHARED_LIBS=TRUE
        -DCMAKE_PREFIX_PATH=${EXTPREFIX}
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

set (_pkg_config_path "${BOOTSTRAP_PREFIX}/lib/pkgconfig" "${BOOTSTRAP_PREFIX}/share/pkgconfig")
cmake_path(CONVERT "$ENV{PKG_CONFIG_PATH}" TO_CMAKE_PATH_LIST _global_pkg_config_path)
list (APPEND _pkg_config_path ${_global_pkg_config_path})

mesonify(_pkg_config_path _mesonified_pkg_config_path)

kis_ExternalProject_Add_with_separate_builds_apple(
    ext_harfbuzz
    MESON

    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/harfbuzz/harfbuzz/releases/download/5.3.1/harfbuzz-5.3.1.tar.xz
    URL_HASH SHA256=4a6ce097b75a8121facc4ba83b5b083bfec657f45b003cd5a3424f2ae6b4434d

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/harfbuzz-clang16-fix.patch
          COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-harfbuzz-Add-global-include-prefix-to-the-list-of-pk.patch

    CONFIGURE_ARGS --prefix=${BOOTSTRAP_PREFIX}
        -Dglib=disabled
        -Dgobject=disabled
        -Dtests=disabled
        -Dfreetype=enabled
        -Dpkgconfig.relocatable=true
        --pkg-config-path ${_mesonified_pkg_config_path}
        ${EXTRA_MESON_FLAGS}

    UPDATE_COMMAND ""

    DEPENDS ext_freetype_bootstrap
)

# Amyspark: just run roughshod!
ExternalProject_Add( ext_freetype
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL ${FREETYPE_URL}
    URL_HASH SHA256=${FREETYPE_SHA256}

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-freetype-Fix-pkgconfig-files-to-be-relocatable.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${BOOTSTRAP_PREFIX}
        -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
        -DFT_DISABLE_BZIP2=ON
        -DFT_DISABLE_BROTLI=ON
        -DFT_REQUIRE_HARFBUZZ=ON
        -DFT_REQUIRE_PNG=ON
        -DBUILD_SHARED_LIBS=TRUE
        -DCMAKE_PREFIX_PATH=${EXTPREFIX}
        ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
    DEPENDS ext_harfbuzz
)

add_custom_target(install_bootstrapped_folder
    COMMAND ${CMAKE_COMMAND} -DSRC=${BOOTSTRAP_PREFIX} -DDST=${EXTPREFIX} -P ${KRITA_CI_INSTALL_DIRECTORY}
    DEPENDS ext_freetype
)

if (NOT TARGET ext_build)
    add_custom_target(ext_build)
endif()
add_dependencies(ext_build ext_freetype)

if (NOT TARGET ext_install)
    add_custom_target(ext_install)
endif()
add_dependencies(ext_install install_bootstrapped_folder)
