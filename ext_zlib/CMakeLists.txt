cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_zlib)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (NOT APPLE)
ExternalProject_Add(
    ext_zlib
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.gz
    URL_HASH SHA1=55eaa84906f31ac20d725aa26cd20839196b6ba6

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Prevent-invalid-inclusions-when-HAVE_-is-set-to-0.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

if(WIN32)
    # Workaround for zlib's library naming bug:
    # https://github.com/madler/zlib/issues/652
    if (MINGW)
        ExternalProject_Add_Step(
            ext_zlib
            pre_install
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libzlib.dll.a <BINARY_DIR>/libz.dll.a
            COMMAND ${CMAKE_COMMAND} -DSRC=<BINARY_DIR>/libz.dll.a -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
            DEPENDERS install
        )
    elseif(MSVC)
        ExternalProject_Add_Step(
            ext_zlib
            pre_install
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/zlib.lib <BINARY_DIR>/z.lib
            COMMAND ${CMAKE_COMMAND} -DSRC=<BINARY_DIR>/z.lib -DDST=${EXTPREFIX}/lib-P  ${KRITA_CI_INSTALL}
            DEPENDERS install
        )
    endif()
endif()

else()
ExternalProject_Add(
    ext_zlib
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.gz
    URL_HASH SHA1=55eaa84906f31ac20d725aa26cd20839196b6ba6

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)
endif()

krita_add_to_ci_targets(ext_zlib)