cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

# OpenSSL has an alternate install target called "install_sw" that skips installing the manual (which is fairly large).
# We use this on android and macos/linux.
project(ext_openssl)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (WIN32)
    if (MSVC)
    # Use the binaries from ConanCenter
        ExternalProject_Add(ext_openssl
            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
            URL https://files.kde.org/krita/build/dependencies/openssl-1.1.1k-win64-msvc.tgz
            URL_HASH SHA256=beae4c78e2f2b64cc3621402a34550ef1fffd08cd35b6a6802f22ed0460ff1d4

            BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying openssl 64-bit dependencies
            CONFIGURE_COMMAND ""
            
            INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include -DDST=${EXTPREFIX}/include -P ${KRITA_CI_INSTALL_DIRECTORY}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/lib/libcrypto.lib -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/lib/libssl.lib -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/libcrypto-1_1-x64.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/libssl-1_1-x64.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}

            UPDATE_COMMAND ""
        )
    else(MSVC)
    # Use the binaries from curl for Windows (https://github.com/curl/curl-for-win).
        ExternalProject_Add(ext_openssl
            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
            URL https://files.kde.org/krita/build/dependencies/openssl-1.1.1l_4-win64-mingw.zip
            URL_HASH SHA256=6582432d4f537323bfa032a1d91b4eee12efdf0c72e4fabdacc0ac5dd1685e9a

            BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying openssl 64-bit dependencies
            CONFIGURE_COMMAND ""
            
            INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include -DDST=${EXTPREFIX}/include -P ${KRITA_CI_INSTALL_DIRECTORY}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/lib/libcrypto.dll.a -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/lib/libssl.dll.a -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/libcrypto-1_1-x64.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                    COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/libssl-1_1-x64.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
            
            UPDATE_COMMAND ""
        )
    endif(MSVC)
elseif (ANDROID)
    ExternalProject_Add( ext_openssl
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.openssl.org/source/openssl-1.1.1m.tar.gz
        URL_HASH SHA256=f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96

        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
            ANDROID_NDK_HOME=${CMAKE_ANDROID_NDK}
            ANDROID_NDK=${CMAKE_ANDROID_NDK}
            PATH=${ANDROID_TOOLCHAIN_ROOT}/bin/:$ENV{PATH}
            <SOURCE_DIR>/Configure android-${CMAKE_ANDROID_ARCH} -D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}
            --prefix=${EXTPREFIX} --openssldir=ssl

        BUILD_COMMAND ${CMAKE_COMMAND} -E env
            PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$ENV{PATH}
            CXXFLAGS=-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}
            make build_libs SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so
        INSTALL_COMMAND ${CMAKE_COMMAND} -E env
            PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$ENV{PATH}
            CXXFLAGS=-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}
            # OpenSSL cannot handle DESTDIR as an environment variable. Instead,
            # it expects it to be passed as an explicit make argument
            ${CMAKE_COMMAND} -DARGS="install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so" -P ${CMAKE_SOURCE_DIR}/run-make-with-destdir.cmake

        UPDATE_COMMAND ""
)
else (WIN32)

    kis_ExternalProject_Add_with_separate_builds_apple(
        ext_openssl

        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.openssl.org/source/openssl-1.1.1m.tar.gz
        URL_HASH SHA256=f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96

        WORKING_DIRECTORY <SOURCE_DIR>
        CONFIGURE_COMMAND <SOURCE_DIR>/config --prefix=${EXTPREFIX} --openssldir=ssl
        
        BUILD_COMMAND make clean COMMAND make -j${SUBMAKE_JOBS} depend COMMAND make -j${SUBMAKE_JOBS}

        # OpenSSL cannot handle DESTDIR as an environment variable. Instead,
        # it expects it to be passed as an explicit make argument
        INSTALL_COMMAND ${CMAKE_COMMAND} -DARGS=install_sw -P ${CMAKE_SOURCE_DIR}/run-make-with-destdir.cmake
        
        UPDATE_COMMAND ""
    )

endif (WIN32)

krita_add_to_ci_targets(ext_openssl)
