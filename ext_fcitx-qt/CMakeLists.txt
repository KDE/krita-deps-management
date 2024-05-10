cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_fcitx5-qt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_fcitx5-qt
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    DOWNLOAD_NAME fcitx5-qt-5.1.3.tar.gz
    URL https://github.com/fcitx/fcitx5-qt/archive/refs/tags/5.1.3.tar.gz
    URL_HASH SHA256=fbf5060e94632cdb80cbe8352c217821ebf7bb961b057ab34153f5e53290109e

    SOURCE_DIR fcitx5-qt-5.1.3
    INSTALL_DIR ${EXTPREFIX}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DENABLE_QT4=OFF -DENABLE_QT5=ON -DENABLE_QT6=OFF -DBUILD_ONLY_PLUGIN=ON

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_fcitx5-qt)
