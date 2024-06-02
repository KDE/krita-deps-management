cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_sonarpen)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set(QT_GIT_TAG "5f3f21d20aff210bcb436199c8601edc364890cd")

if (ANDROID)
    ExternalProject_Add(
        ext_sonarpen
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        GIT_REPOSITORY https://invent.kde.org/greenblub/sonarpen.git
        GIT_TAG ${QT_GIT_TAG}
        GIT_PROGRESS true
        GIT_REMOTE_UPDATE_STRATEGY REBASE

        INSTALL_DIR ${EXTPREFIX}
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_sonarpen)