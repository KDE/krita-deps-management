cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_fcitx5-qt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_fcitx5-qt
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME fcitx5-qt-5.1.7.tar.gz
    URL https://github.com/fcitx/fcitx5-qt/archive/refs/tags/5.1.7.tar.gz
    URL_HASH SHA256=586e35e70e656ce387d7c87b58af1294599bd10385f983580235a2efeca666ee

    SOURCE_DIR fcitx5-qt-5.1.7
    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}
        -DENABLE_QT4=OFF
        -DENABLE_QT5=OFF
        -DENABLE_QT6=ON
        -DBUILD_ONLY_PLUGIN=ON

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_fcitx5-qt)
