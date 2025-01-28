cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_lager)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set(EXTRA_LAGER_ARGS)

if (MINGW AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    string(REGEX REPLACE "([0-9])\\.([0-9])(\\.[0-9])?" "\\1"
        KRITA_boost_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
    set(EXTRA_LAGER_ARGS "-DBoost_COMPILER=mgw${KRITA_boost_COMPILER_VERSION}")
endif()

ExternalProject_Add( ext_lager
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    GIT_REPOSITORY https://github.com/dimula73/lager.git
    GIT_TAG 0b6ab3e0e880bc36be5da4984d768fde03b7cf19

    PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Correctly-use-global-namespace-to-resolve-lager-deta.patch
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Fix-attempt-to-use-final-specifier-with-a-non-virtua.patch

    CMAKE_ARGS -Dlager_BUILD_DEBUGGER_EXAMPLES=OFF
       -Dlager_BUILD_TESTS=OFF
       -Dlager_BUILD_EXAMPLES=OFF
       -Dlager_BUILD_DOCS=OFF
       ${EXTRA_LAGER_ARGS}
       -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
       -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
       ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_lager)
