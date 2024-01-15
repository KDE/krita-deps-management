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
set (KRITA_CI_FIX_PYTHON_SHEBANG_LINES ${CMAKE_CURRENT_LIST_DIR}/fixup-shebang-lines.cmake)
set (KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT ${CMAKE_CURRENT_LIST_DIR}/run-make-with-install-root.cmake)
set (KRITA_CI_RUN_MAKE_WITH_DESTDIR ${CMAKE_CURRENT_LIST_DIR}/run-make-with-destdir.cmake)
set (KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR ${CMAKE_CURRENT_LIST_DIR}/run-pip-install-with-destdir.cmake)
set (KRITA_CI_RUN_SETUP_PY_WITH_DESTDIR ${CMAKE_CURRENT_LIST_DIR}/run-setup-py-with-destdir.cmake)


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
endif()
file(TO_CMAKE_PATH "${EXTERNALS_DOWNLOAD_DIR}" EXTERNALS_DOWNLOAD_DIR)

if(NOT IS_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    if (CMAKE_INSTALL_PREFIX)
        file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    else()
        message(FATAL_ERROR "No install dir set. Use -DCMAKE_INSTALL_PREFIX")
    endif()
endif()
file(TO_CMAKE_PATH "${CMAKE_INSTALL_PREFIX}" CMAKE_INSTALL_PREFIX)

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
endif ()

find_program(Patch_EXECUTABLE patch)
if (Patch_EXECUTABLE)
    message(STATUS "Found patch: ${Patch_EXECUTABLE}")

    set(PATCH_COMMAND ${Patch_EXECUTABLE})
else()
    message(STATUS "Patch command is NOT found!")
    set(PATCH_COMMAND patch)
endif()

if (WIN32 OR LINUX)
option(QT_ENABLE_DEBUG_INFO "Build Qt with full debug info included" OFF)
option(QT_ENABLE_ASAN "Build Qt with ASAN" OFF)
endif()

set(SECURITY_EXE_LINKER_FLAGS "")
set(SECURITY_SHARED_LINKER_FLAGS "")
set(SECURITY_MODULE_LINKER_FLAGS "")

if (MINGW)
	option(USE_MINGW_HARDENING_LINKER "Enable DEP (NX), ASLR and high-entropy ASLR linker flags (mingw-w64)" ON)
	if (USE_MINGW_HARDENING_LINKER)
		set(SECURITY_EXE_LINKER_FLAGS "-Wl,--dynamicbase -Wl,--nxcompat -Wl,--disable-auto-image-base")
		set(SECURITY_SHARED_LINKER_FLAGS "-Wl,--dynamicbase -Wl,--nxcompat -Wl,--disable-auto-image-base")
		set(SECURITY_MODULE_LINKER_FLAGS "-Wl,--dynamicbase -Wl,--nxcompat -Wl,--disable-auto-image-base")
        # Enable high-entropy ASLR for 64-bit
        # The image base has to be >4GB for HEASLR to be enabled.
        # The values used here are kind of arbitrary.
        set(SECURITY_EXE_LINKER_FLAGS "${SECURITY_EXE_LINKER_FLAGS} -Wl,--high-entropy-va -Wl,--image-base,0x140000000")
        set(SECURITY_SHARED_LINKER_FLAGS "${SECURITY_SHARED_LINKER_FLAGS} -Wl,--high-entropy-va -Wl,--image-base,0x180000000")
        set(SECURITY_MODULE_LINKER_FLAGS "${SECURITY_MODULE_LINKER_FLAGS} -Wl,--high-entropy-va -Wl,--image-base,0x180000000")
        set(GLOBAL_PROFILE ${GLOBAL_PROFILE}
            -DCMAKE_EXE_LINKER_FLAGS=${SECURITY_EXE_LINKER_FLAGS}
            -DCMAKE_SHARED_LINKER_FLAGS=${SECURITY_SHARED_LINKER_FLAGS}
            -DCMAKE_MODULE_LINKER_FLAGS=${SECURITY_MODULE_LINKER_FLAGS}
        )
	else ()
		message(WARNING "Linker Security Flags not enabled!")
	endif ()

    # Generate reduced debug info
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -g1")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g1")

    # Clang does not generate DWARF aranges data by default, which makes
    # DrMingw not able to parse the DWARF debug symbols. Add -gdwarf-aranges
    # explicitly.
    # See: https://github.com/jrfonseca/drmingw/issues/42#issuecomment-516614561
    #
    # `-fdebug-info-for-profiling` is needed for proper C++ function signatures
    # when using Clang with `-g1`.
    if (CMAKE_C_COMPILER_ID STREQUAL "Clang")
        set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -gdwarf-aranges -fdebug-info-for-profiling")
    endif ()
    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -gdwarf-aranges -fdebug-info-for-profiling")
    endif ()

    set(GLOBAL_PROFILE ${GLOBAL_PROFILE}
        -DCMAKE_C_FLAGS_RELWITHDEBINFO=${CMAKE_C_FLAGS_RELWITHDEBINFO}
        -DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}
    )
elseif (MSVC)
    set(SECURITY_C_FLAGS "")
    set(SECURITY_CXX_FLAGS "")
	# Increase the stack size to match MinGW's. Prevents crashes with GMic.
    set(SECURITY_EXE_LINKER_FLAGS "/STACK:4194304")
    set(SECURITY_SHARED_LINKER_FLAGS "/STACK:4194304")
    set(SECURITY_MODULE_LINKER_FLAGS "/STACK:4194304")
	option(USE_CONTROL_FLOW_GUARD "Enable Control Flow Guard hardening (MSVC)" ON)
	if (USE_CONTROL_FLOW_GUARD)
        set(SECURITY_C_FLAGS "/guard:cf")
        set(SECURITY_CXX_FLAGS "/guard:cf")
        set(SECURITY_EXE_LINKER_FLAGS "/GUARD:CF")
        set(SECURITY_SHARED_LINKER_FLAGS "/GUARD:CF")
        set(SECURITY_MODULE_LINKER_FLAGS "/GUARD:CF")
	endif (USE_CONTROL_FLOW_GUARD)
	set(GLOBAL_PROFILE ${GLOBAL_PROFILE}
		-DCMAKE_C_FLAGS=${SECURITY_C_FLAGS}
		-DCMAKE_CXX_FLAGS=${SECURITY_CXX_FLAGS}
		-DCMAKE_EXE_LINKER_FLAGS=${SECURITY_EXE_LINKER_FLAGS}
		-DCMAKE_SHARED_LINKER_FLAGS=${SECURITY_SHARED_LINKER_FLAGS}
		-DCMAKE_MODULE_LINKER_FLAGS=${SECURITY_MODULE_LINKER_FLAGS}
	)
endif ()

if (MSYS)
    set(GLOBAL_PROFILE ${GLOBAL_PROFILE}
                           -DCMAKE_TOOLCHAIN_FILE=${MXE_TOOLCHAIN}
                           -DCMAKE_FIND_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                           -DCMAKE_SYSTEM_INCLUDE_PATH=${CMAKE_PREFIX_PATH}/include
                           -DCMAKE_INCLUDE_PATH=${CMAKE_PREFIX_PATH}/include
                           -DCMAKE_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib
                           -DZLIB_ROOT=${CMAKE_PREFIX_PATH}
    )
    set(GLOBAL_AUTOMAKE_PROFILE  --host=i686-pc-mingw32 )
endif()

if (APPLE)
    set(PARENT_CMAKE_SOURCE_DIR ${CMAKE_SOURCE_DIR})
    string(REPLACE ";" "$<SEMICOLON>" CMAKE_OSX_ARCHITECTURES_ESCAPED "${CMAKE_OSX_ARCHITECTURES}")
    set(GLOBAL_PROFILE ${GLOBAL_PROFILE}
                        -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
                        -DCMAKE_INCLUDE_PATH:PATH=${CMAKE_PREFIX_PATH}/include
                        -DCMAKE_LIBRARY_PATH:PATH=${CMAKE_PREFIX_PATH}/lib
                        -DCMAKE_MACOSX_RPATH=ON
                        -DKDE_SKIP_RPATH_SETTINGS=ON
                        -DBUILD_WITH_INSTALL_RPATH=ON
                        -DAPPLE_SUPPRESS_X11_WARNING=ON
                        -DCMAKE_FIND_FRAMEWORK=LAST
                        -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES_ESCAPED}
    )

    list(LENGTH CMAKE_OSX_ARCHITECTURES MACOS_ARCHS)
    list(JOIN CMAKE_OSX_ARCHITECTURES " " CMAKE_OSX_ARCHITECTURES_STR)

    foreach(arch ${CMAKE_OSX_ARCHITECTURES})
        string(APPEND MACOS_ARCH_FLAGS "-arch ${arch} ")
    endforeach()
    string(STRIP "${MACOS_ARCH_FLAGS}" MACOS_ARCH_FLAGS)

    set(GLOBAL_AUTOMAKE_PROFILE 
        "CFLAGS=${MACOS_ARCH_FLAGS}"
        "CXXFLAGS=${MACOS_ARCH_FLAGS}"
    )
endif ()

if (ANDROID)
  # Increase the stack size to match MinGW's. Prevents crashes with GMic.
  set(SECURITY_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-z,stack-size=4194304")
  set(SECURITY_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,stack-size=4194304")
  set(SECURITY_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-z,stack-size=4194304")

  string(REPLACE ";" "$<SEMICOLON>" _escape_find_root_path "${CMAKE_FIND_ROOT_PATH}")
  # stl must be consistent: https://github.com/android/ndk/issues/1441
  set (GLOBAL_PROFILE ${GLOBAL_PROFILE}
                     -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
                     -DANDROID_PLATFORM=${ANDROID_PLATFORM}
                     -DANDROID_ABI=${ANDROID_ABI}
                     -DANDROID_STL=${ANDROID_STL}
                     -DCMAKE_FIND_ROOT_PATH=${_escape_find_root_path}
                     -DCMAKE_EXE_LINKER_FLAGS=${SECURITY_EXE_LINKER_FLAGS}
                     -DCMAKE_SHARED_LINKER_FLAGS=${SECURITY_SHARED_LINKER_FLAGS}
                     -DCMAKE_MODULE_LINKER_FLAGS=${SECURITY_MODULE_LINKER_FLAGS})
endif()
