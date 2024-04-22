# Note: We explicitly set CMAKE_CXX_STANDARD=14 when compiling exiv2 because
# it uses `auto_ptr`, which has been removed in c++17. Clang 16 switches to
# using -std=c++17 by default, and that causes build failures with libc++.

# FIXME: Remove this setting when exiv2 has been updated to remove usage of
# `auto_ptr`, and also remove the workaround in `FindLibExiv2.cmake`.

cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_exiv2)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (ANDROID)
    ExternalProject_Add(
        ext_exiv2

        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/Exiv2/exiv2/releases/download/v0.27.5/exiv2-0.27.5-Source.tar.gz
        URL_HASH SHA256=35a58618ab236a901ca4928b0ad8b31007ebdc0386d904409d825024e45ea6e2

        CMAKE_ARGS -DCMAKE_CXX_STANDARD=14 -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DEXIV2_BUILD_SAMPLES=OFF -DICONV_LIBRARY=${EXTPREFIX}/lib -DEXIV2_ENABLE_NLS=OFF -DICONV_INCLUDE_DIR=${EXTPREFIX}/include -DEXPAT_LIBRARY=${EXTPREFIX}/lib/libexpat.so -DEXPAT_INCLUDE_DIR=${EXTPREFIX}/include -DEXIV2_BUILD_EXIV2_COMMAND=OFF
        UPDATE_COMMAND ""
    )

elseif(WIN32)

    set(WINDOWS_PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-building-exiv2-with-TDMGCC-10.3.0.patch)

    set(WINDOWS_PATCH_COMMAND 
        ${WINDOWS_PATCH_COMMAND}
        COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/01_fpermissive_error.patch)

    ExternalProject_Add(
        ext_exiv2
        
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/Exiv2/exiv2/releases/download/v0.27.5/exiv2-0.27.5-Source.tar.gz
        URL_HASH SHA256=35a58618ab236a901ca4928b0ad8b31007ebdc0386d904409d825024e45ea6e2

        PATCH_COMMAND ${WINDOWS_PATCH_COMMAND}

        CMAKE_ARGS -DCMAKE_CXX_STANDARD=14 -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_LIBRARY_PATH=${EXTPREFIX}/lib -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DEXIV2_BUILD_SAMPLES=OFF -DIconv_INCLUDE_DIR=${EXTPREFIX}/include -DEXIV2_ENABLE_NLS=OFF -DEXIV2_BUILD_EXIV2_COMMAND=OFF

        UPDATE_COMMAND ""
    )
else()
    ExternalProject_Add(
        ext_exiv2

        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/Exiv2/exiv2/releases/download/v0.27.5/exiv2-0.27.5-Source.tar.gz
        URL_HASH SHA256=35a58618ab236a901ca4928b0ad8b31007ebdc0386d904409d825024e45ea6e2

        CMAKE_ARGS -DCMAKE_CXX_STANDARD=14 -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_LIBRARY_PATH=${EXTPREFIX}/lib 
            -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE} -DEXIV2_BUILD_SAMPLES=OFF -DIconv_INCLUDE_DIR=${EXTPREFIX}/include
            -DEXIV2_ENABLE_NLS=OFF -DEXIV2_BUILD_EXIV2_COMMAND=OFF -DCMAKE_CXX_FLAGS=-Wno-deprecated

        UPDATE_COMMAND ""
    )
    
endif()

krita_add_to_ci_targets(ext_exiv2)
