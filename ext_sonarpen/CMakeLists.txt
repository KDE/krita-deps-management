cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_sonarpen)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set(QT_GIT_TAG "c260a15fc0be875ace42fd58a8d3c2bf986953a8")

if (ANDROID)
  ExternalProject_Add(
      ext_sonarpen
      DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
      GIT_REPOSITORY https://invent.kde.org/greenblub/sonarpen.git
      GIT_TAG ${QT_GIT_TAG}
      GIT_PROGRESS true
      GIT_REMOTE_UPDATE_STRATEGY REBASE

      INSTALL_DIR ${EXTPREFIX}

      UPDATE_COMMAND ""
      BUILD_IN_SOURCE 0
)
endif()

krita_add_to_ci_targets(ext_sonarpen)