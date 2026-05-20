cmake_minimum_required(VERSION 3.29)

project(ext_kitemmodels)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kitemmodels
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/5.101/kitemmodels-5.101.0.tar.xz
    URL_HASH SHA256=5aaee068a8d0c85dfc50c5ade2c5eb913c5936f68e902c302c36bbc2ac70f426

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kitemmodels)
