cmake_minimum_required(VERSION 3.21)

#
# Build all dependencies for Krita and finally Krita itself.
# Parameters: EXTERNALS_DOWNLOAD_DIR place to download all packages
#             CMAKE_INSTALL_PREFIX place to install everything to
#             MXE_TOOLCHAIN: the toolchain file to cross-compile using MXE
#
# Example usage: cmake ..\kritadeposx -DEXTERNALS_DOWNLOAD_DIR=/dev2/d -DCMAKE_INSTALL_PREFIX=/dev2/i -DWIN64_BUILD=TRUE  -DBOOST_LIBRARYDIR=/dev2/i/lib   -G "Visual Studio 11 Win64"

if(APPLE)
        execute_process(COMMAND sysctl -n hw.optional.arm64 OUTPUT_VARIABLE apple_has_arm64_optional)
        if(apple_has_arm64_optional)
                message(STATUS "Building on macos arm")
                cmake_minimum_required(VERSION 3.19.3)
	else()
        cmake_minimum_required(VERSION 3.7.2)
	endif()
else(APPLE)
	cmake_minimum_required(VERSION 3.7.0 FATAL_ERROR)
endif()


#
# If you add a new dependency into 3rdparty folder, do **not** overide
# BUILD_COMMAND and INSTALL_COMMAND with their '-j${SUBMAKE_JOBS}' equivalents,
# unless you need a really custom command for this dep. CMake will pass the
# correct threading option to make/ninja automatically. The variable below is
# Used **only** by custom builds, like sip and boost.
#

if (NOT SUBMAKE_JOBS)
    include(ProcessorCount)
    ProcessorCount(NUM_CORES)
    if  (NOT NUM_CORES EQUAL 0)
        if (NUM_CORES GREATER 2)
            # be nice...
            MATH( EXPR NUM_CORES "${NUM_CORES} - 2" )
        endif()
        set(SUBMAKE_JOBS ${NUM_CORES})
    else()
        set(SUBMAKE_JOBS 1)
    endif()
endif()

MESSAGE("SUBMAKE_JOBS: " ${SUBMAKE_JOBS})

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
	message(FATAL_ERROR "Compiling in the source directory is not supported. Use for example 'mkdir build; cd build; cmake ..'.")
endif (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)

# Tools must be obtained to work with:
include (ExternalProject)

LIST (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../cmake/kde_macro")
LIST (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../cmake/")
LIST (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
include (KritaToNativePath)
include (KritaExternalProject)

include (KritaAddToCiTargets)
set (KRITA_CI_INSTALL ${CMAKE_CURRENT_LIST_DIR}/install_custom.cmake)
set (KRITA_CI_INSTALL_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/install_directory_custom.cmake)
set (KRITA_CI_REMOVE_AT_PREFIX ${CMAKE_CURRENT_LIST_DIR}/remove-at-prefix.cmake)

# set property on the root directory to make sure that all external projects
# have separate build and install targets (to be used in krita_add_to_ci_targets())
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY EP_STEP_TARGETS "build;install")

# allow specification of a directory with pre-downloaded
# requirements
if(DEFINED ENV{EXTERNALS_DOWNLOAD_DIR})
    set(EXTERNALS_DOWNLOAD_DIR $ENV{EXTERNALS_DOWNLOAD_DIR})
endif()

if(NOT IS_DIRECTORY ${EXTERNALS_DOWNLOAD_DIR})
    if (EXTERNALS_DOWNLOAD_DIR)
        file(MAKE_DIRECTORY ${EXTERNALS_DOWNLOAD_DIR})
    else()
        message(FATAL_ERROR "No externals download dir set. Use -DEXTERNALS_DOWNLOAD_DIR")
    endif()
else()
    file(TO_CMAKE_PATH "${EXTERNALS_DOWNLOAD_DIR}" EXTERNALS_DOWNLOAD_DIR)
endif()

if(NOT IS_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    if (CMAKE_INSTALL_PREFIX)
        file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    else()
        message(FATAL_ERROR "No install dir set. Use -DCMAKE_INSTALL_PREFIX")
    endif()
else()
    file(TO_CMAKE_PATH "${CMAKE_INSTALL_PREFIX}" CMAKE_INSTALL_PREFIX)
endif()

set(TOP_INST_DIR ${CMAKE_INSTALL_PREFIX})
set(EXTPREFIX "${TOP_INST_DIR}")
set(CMAKE_PREFIX_PATH "${EXTPREFIX}")

if (${CMAKE_GENERATOR} STREQUAL "Visual Studio 14 2015 Win64")
    SET(GLOBAL_PROFILE
        -DCMAKE_MODULE_LINKER_FLAGS=/machine:x64
        -DCMAKE_EXE_LINKER_FLAGS=/machine:x64
        -DCMAKE_SHARED_LINKER_FLAGS=/machine:x64
        -DCMAKE_STATIC_LINKER_FLAGS=/machine:x64
    )
endif ()

message( STATUS "CMAKE_GENERATOR: ${CMAKE_GENERATOR}")
message( STATUS "CMAKE_CL_64: ${CMAKE_CL_64}")

set(GLOBAL_BUILD_TYPE RelWithDebInfo)
set(GLOBAL_PROFILE ${GLOBAL_PROFILE} -DBUILD_TESTING=false)

if (UNIX AND NOT APPLE)
        set(LINUX true)
    set(PATCH_COMMAND patch)
elseif (WIN32)
    set(PATCH_COMMAND patch)
endif ()

if (WIN32 OR LINUX)
option(QT_ENABLE_DEBUG_INFO "Build Qt with full debug info included" OFF)
option(QT_ENABLE_ASAN "Build Qt with ASAN" OFF)
endif()
