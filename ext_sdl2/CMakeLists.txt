cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_sdl2)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (ANDROID)
    ExternalProject_Add(
        ext_sdl2
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        GIT_REPOSITORY https://github.com/sh-zam/SDL-android-glue.git
        GIT_TAG 9facc86b6add4e3a02d2ef499a4cf4e82302e189

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
            -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
            -DBUILD_SHARED_LIBS=TRUE -DSDL_ANDROID_AUDIO_STRIPPED=ON -DSDL_HAPTIC=OFF
            -DSDL_JOYSTICK=OFF -DSDL_VIDEO=OFF -DSDL_SENSOR=OFF -DSDL_MISC=OFF -DSDL_POWER=OFF
            -DSDL_LOCALE=OFF -DSDL_FILESYSTEM=OFF -DINSTALL_JARS_PATH=${EXTPREFIX}/jar
            -DANDROID_SDK=${ANDROID_SDK_ROOT} -DANDROID_JAVA_PLATFORM_API=${ANDROID_SDK_COMPILE_API}
            ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
    )
else()
    ExternalProject_Add(
        ext_sdl2
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/libsdl-org/SDL/releases/download/release-2.32.10/SDL2-2.32.10.tar.gz
        URL_HASH SHA256=5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165

        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX}
            -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE}
            -DBUILD_SHARED_LIBS=TRUE
            ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_sdl2)
