cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_pkgconfig)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_meson.cmake)

# we build pkgconfig only on MacOS and Windows
if (APPLE)
    ExternalProject_Add( ext_pkgconfig
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
        URL_MD5 f6e931e319531b736fadc017f470e68a

        BUILD_IN_SOURCE 1

        CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE} --with-internal-glib
    )
else(WIN32)

    ExternalProject_Add( ext_pkgconfig
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        GIT_REPOSITORY https://github.com/pkgconf/pkgconf.git
        GIT_TAG pkgconf-1.9.3

        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
            PYTHONPATH=${_krita_pythonpath}
            PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
            ${MESON_BINARY_PATH} setup <BINARY_DIR> <SOURCE_DIR>
                --prefix=${EXTPREFIX}
                --libdir=lib
                -Dbuildtype=$<IF:$<CONFIG:Debug>,debug,debugoptimized>
                -Dtests=false
                ${EXTRA_MESON_FLAGS}

        BUILD_COMMAND ${CMAKE_COMMAND} -E env
            PYTHONPATH=${_krita_pythonpath}
            ${MESON_BINARY_PATH} compile -C <BINARY_DIR> -j${SUBMAKE_JOBS}

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env
            PYTHONPATH=${_krita_pythonpath}
            ${MESON_BINARY_PATH} install -C <BINARY_DIR>

        UPDATE_COMMAND ""
)
endif()

krita_add_to_ci_targets(ext_pkgconfig)