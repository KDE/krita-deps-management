cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_icoutils)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (MINGW)

    #
    # WARNING: please don't use links to http://savannah.nongnu.org, since it is
    #          very unstable
    #

    ExternalProject_Add(
        ext_icoutils
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.kde.org/krita/build/dependencies/icoutils-0.32.3.tar.bz2
        URL_HASH SHA256=17abe02d043a253b68b47e3af69c9fc755b895db68fdc8811786125df564c6e0

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Really-do-not-include-libintl.h.patch
              COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-CMake-to-build-icotool.exe.patch
              COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Add-prototype-args-to-function-pointer.patch
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
    )

elseif (MSVC)

    ExternalProject_Add(
        ext_icoutils
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.kde.org/krita/build/dependencies/icoutils-bin-0.32.3.tar.gz
        URL_HASH SHA256=e2de7f65a82ff0f0377002f9cfb4182ec8bbd7de6d714bb7ae40af8da5d8a451

        INSTALL_DIR ${EXTPREFIX}

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying icoutils
        INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/icotool.exe -DDST=${EXTPREFIX}/bin/ -P ${KRITA_CI_INSTALL}

        UPDATE_COMMAND ""
    )

endif (MINGW)

krita_add_to_ci_targets(ext_icoutils)
