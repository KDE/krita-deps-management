cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

# IMPORTANT NOTE
#
# We don't use boost::system in Krita, but we should pass at least
# something to ./b2 to make sure boost doesn't try to build anything
# non-header-only; (boost::system itself is a header-only library, so
# it will not result in any module either!)

project(ext_boost)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if(WIN32)
    if(MINGW)

        string(REGEX REPLACE "([0-9])\\.([0-9])(\\.[0-9])?" "\\1"
            KRITA_boost_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})

        # Detect architecture
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64|aarch64|arm64")
            set(BOOST_ARCH "arm")
            set(BOOST_ADDR_MODEL "64")
            set(BOOST_PLATFORM_TAG "a64")  # ARM64 platform tag
        else()
            set(BOOST_ARCH "x86")
            set(BOOST_ADDR_MODEL "64")
            set(BOOST_PLATFORM_TAG "x64")  # x86-64 platform tag
        endif()

        set (BUILD_ARGS -j${SUBMAKE_JOBS} linkflags="${SECURITY_SHARED_LINKER_FLAGS}"
            --with-system --build-dir=build-dir toolset=gcc variant=release
            link=shared threading=multi
            architecture=${BOOST_ARCH} address-model=${BOOST_ADDR_MODEL})

        ExternalProject_Add(
            ext_boost

            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

            URL https://archives.boost.io/release/1.90.0/source/boost_1_90_0.tar.bz2
            URL_HASH SHA256=49551aff3b22cbc5c5a9ed3dbc92f0e23ea50a0f7325b0d198b705e8ee3fc305

            CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.bat gcc --prefix=${EXTPREFIX}
            BUILD_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${BUILD_ARGS}
            INSTALL_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${BUILD_ARGS} -d0 install

            UPDATE_COMMAND ""
            BUILD_IN_SOURCE 1
        )

        if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            message(STATUS "Applying Clang override to Boost...")
            set(_user_config "using gcc : : ${CMAKE_CXX_COMPILER} ;")
            file(WRITE 
                ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam
                "${_user_config}"
            )
            ExternalProject_Add_Step(
                ext_boost
                configure_clang_mingw
                COMMAND ${CMAKE_COMMAND} -E rm <SOURCE_DIR>/project-config.jam
                DEPENDEES configure
                DEPENDERS build
            )
            ExternalProject_Add_Step(
                ext_boost
                patch_clang_mingw
                COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam <SOURCE_DIR>/tools/build/src/user-config.jam
                DEPENDEES patch
                DEPENDERS configure
            )
        endif()
    else()
        set (BUILD_ARGS -j${SUBMAKE_JOBS} --with-system --build-dir=build-dir toolset=msvc variant=release link=shared threading=multi architecture=x86 install)

        # Boost.Build cannot append arbitrary flags to MSVC from the command line.
        # It becomes unable to detect the target architecture or defaults to x86 only.
        # On top of that, parameterizing the linkflags flag breaks the MinGW build.
        ExternalProject_Add(
            ext_boost
            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

            URL https://archives.boost.io/release/1.90.0/source/boost_1_90_0.tar.bz2
            URL_HASH SHA256=49551aff3b22cbc5c5a9ed3dbc92f0e23ea50a0f7325b0d198b705e8ee3fc305

            CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.bat msvc --prefix=${EXTPREFIX}
            BUILD_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${BUILD_ARGS}
            INSTALL_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${BUILD_ARGS} install

            UPDATE_COMMAND ""
            BUILD_IN_SOURCE 1
        )
        if (NOT DEFINED MSVC_TOOLSET_VERSION)
            string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" KRITA_boost_COMPILER ${CMAKE_CXX_COMPILER})
            string(REGEX REPLACE "^([0-9]+)\\.([0-9]).+$" "\\1\\2"
            KRITA_boost_COMPILER_VERSION ${KRITA_boost_COMPILER})
        else()
            set(KRITA_boost_COMPILER_VERSION ${MSVC_TOOLSET_VERSION})
        endif()
    endif()
elseif(ANDROID)
    set (BUILD_ARGS --with-libraries=system --boost=1.90.0 --arch=${ANDROID_ABI} ${CMAKE_ANDROID_NDK})

    ExternalProject_Add( ext_boost
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        DOWNLOAD_NAME boost-2335700042dc9882c5d03e210f9f58ab3ac83b58.tar.gz
        URL https://github.com/moritz-wundke/Boost-for-Android/archive/6dcf8c41657d2e5829253009137302a576a174cb.tar.gz
        URL_HASH SHA256=ebdab9383a15e21c0e0829c6c483276f5d04c8f0612227021713c4f761594a95

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Add-support-for-NDK-27.X-and-30.0.patch

        CONFIGURE_COMMAND ""
        # no prefix is passed, we will install it ourselves!
        BUILD_COMMAND <SOURCE_DIR>/build-android.sh ${BUILD_ARGS}
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Installing Boost..."

        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 1
    )

    ExternalProject_Add_Step(
        ext_boost
        pre_install
        COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/build/out/${ANDROID_ABI}/lib -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL_DIRECTORY}
        COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/build/out/${ANDROID_ABI}/include -DDST=${EXTPREFIX}/include -P ${KRITA_CI_INSTALL_DIRECTORY}
        DEPENDERS install
    )

else()
    if(APPLE)
        set(MACOS_BOOST_ARGS \"architecture=arm+x86\" \"cxxflags=${MACOS_ARCH_FLAGS}\")
    endif()
    ExternalProject_Add( ext_boost
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

        URL https://archives.boost.io/release/1.90.0/source/boost_1_90_0.tar.bz2
        URL_HASH SHA256=49551aff3b22cbc5c5a9ed3dbc92f0e23ea50a0f7325b0d198b705e8ee3fc305

        CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh --prefix=${EXTPREFIX} --with-libraries=system
        
        BUILD_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${MACOS_BOOST_ARGS}
        INSTALL_COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/run-b2-with-destdir.cmake -- ${MACOS_BOOST_ARGS} -d0 install

        UPDATE_COMMAND ""
        BUILD_IN_SOURCE 1
    )
endif()

krita_add_to_ci_targets(ext_boost)
