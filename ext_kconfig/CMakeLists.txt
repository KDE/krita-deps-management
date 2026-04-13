cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_kconfig)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

ExternalProject_Add(
    ext_kconfig
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    URL https://download.kde.org/stable/frameworks/6.25/kconfig-6.25.0.tar.xz
    URL_HASH SHA256=8c675c9d35a866fbf1b564354a589019b429cca949f7ba3ba0adb9f2fa15959c

    # Dropped patches (might be related to the placement of kritarc config file or service detection):
    # 0001-Patch-kconfig-to-save-the-config-to-AppConfigLocatio.patch

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} -DBUILD_TESTING=OFF -DKCONFIG_USE_DBUS=OFF ${GLOBAL_PROFILE}

    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_kconfig)
