cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

macro(mesonify VAR DEST)
    set(${DEST} "${${VAR}}")
    separate_arguments(${DEST})
    if (MSVC) # Fix compiler flags
        list(TRANSFORM ${DEST} REPLACE "^\/" "-")
    endif()
    list(TRANSFORM ${DEST} REPLACE "(.+)" "\'\\1\'")
    list(FILTER ${DEST} EXCLUDE REGEX "^$")
    list(JOIN ${DEST} "," ${DEST})
    set(${DEST} "[${${DEST}}]")
endmacro()

if (ANDROID OR (CMAKE_CROSSCOMPILING AND NOT APPLE))
    set(CROSS_COMPILE_FLAGS "--sysroot=${CMAKE_SYSROOT}")
    set(CROSS_LINKER_FLAGS "--sysroot=${CMAKE_SYSROOT}")
elseif (APPLE)
    set(CROSS_COMPILE_FLAGS "-isysroot ${CMAKE_OSX_SYSROOT}")
    set(CROSS_LINKER_FLAGS "-isysroot ${CMAKE_OSX_SYSROOT}")
endif()

if (ANDROID OR CMAKE_CROSSCOMPILING)
    set(CROSS_COMPILE_FLAGS "${CROSS_COMPILE_FLAGS} --target=${CMAKE_C_COMPILER_TARGET}")
    set(CROSS_LINKER_FLAGS "${CROSS_EXE_LINKER_FLAGS} --target=${CMAKE_C_COMPILER_TARGET}")
endif()

if (ANDROID)
# Meson injects -D_FILE_OFFSET_BITS=64 which triggers off_t functions.
# Alternatively, increase API level to 24.
    set(CROSS_COMPILE_FLAGS "${CROSS_COMPILE_FLAGS} -D_LIBCPP_HAS_NO_OFF_T_FUNCTIONS")
endif()

if (CMAKE_OSX_ARCHITECTURES)
    foreach(arch ${CMAKE_OSX_ARCHITECTURES})
        string(APPEND CROSS_COMPILE_FLAGS_${arch} "${CROSS_COMPILE_FLAGS} -arch ${arch}")
    endforeach()
endif()

mesonify(SECURITY_C_FLAGS _security_c_flags)
mesonify(SECURITY_CXX_FLAGS _security_cxx_flags)
mesonify(SECURITY_EXE_LINKER_FLAGS _security_exe_linker_flags)
mesonify(CROSS_COMPILE_FLAGS _cross_compile_flags)
mesonify(CROSS_LINKER_FLAGS _cross_linker_flags)

# Block any libraries not coming from our PATH when crosscompiling
if (UNIX AND CMAKE_CROSSCOMPILING)
    set(_pkg_config_libdir "pkg_config_libdir = ''")
else()
    # In Windows either we pick up the MSYS2 pkg-config
    # or we ship our own, both use the correct architecture.
    # Linux also uses the correct architecture.
    set(_pkg_config_libdir)
endif()

include(TestBigEndian)
test_big_endian(IS_ENDIAN)
set(CROSSCOMPILING REQUIRED)

if (IS_ENDIAN)
    set(_endian "big")
else()
    set(_endian "little")
endif()

string(TOLOWER ${CMAKE_SYSTEM_NAME} _system_name)

if (ANDROID OR CMAKE_CROSSCOMPILING)
    set(EXTRA_MESON_FLAGS
        --cross-file=${CMAKE_CURRENT_BINARY_DIR}/meson-compiler.ini
        --cross-file=${CMAKE_CURRENT_BINARY_DIR}/meson-host.ini
    )
    set(CROSSCOMPILING REQUIRED)
else()
    set(EXTRA_MESON_FLAGS
        --native-file=${CMAKE_CURRENT_BINARY_DIR}/meson-compiler.ini
    )
    set(CROSSCOMPILING)
endif()

if (MSVC)
    set(_c_ld "c_ld = ['${CMAKE_LINKER}'] + cross_link_args")
    set(_cpp_ld "cpp_ld = ['${CMAKE_LINKER}'] + cross_link_args")
endif()

if (NOT MESON_BINARY_PATH)
    find_program(Meson_EXECUTABLE meson)

    if (Meson_EXECUTABLE)
        execute_process(COMMAND meson --version OUTPUT_VARIABLE Meson_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)

        message(STATUS "Found meson (${Meson_VERSION}): ${Meson_EXECUTABLE}")

        if (${Meson_VERSION} VERSION_LESS "1.1.0")
            message(FATAL_ERROR "Meson executable is too old! Krita requires at least meson 1.1.0")
        endif()

        set(MESON_BINARY_PATH ${Meson_EXECUTABLE})
    else()
        set(MESON_BINARY_PATH ${EXTPREFIX}/bin/meson)
        message(STATUS "Meson not available, using 3rdparty version.")

        if (NOT EXISTS ${MESON_BINARY_PATH})
            message(FATAL_ERROR "Meson executable is not found in 3rdparty install directory!")
        endif()
    endif()
endif()

set(MESON_NASM_PATH "${EXTPREFIX}/bin/nasm${CMAKE_EXECUTABLE_SUFFIX}")

find_package(PkgConfig)

if (NOT PKG_CONFIG_FOUND OR WIN32)
    if (NOT WIN32)
        set(PKG_CONFIG_EXECUTABLE ${EXTPREFIX}/bin/pkg-config)
    else()
        set(PKG_CONFIG_EXECUTABLE ${EXTPREFIX}/bin/pkgconf.exe)
    endif()

    if (NOT EXISTS ${PKG_CONFIG_EXECUTABLE})
        message("WARNING: pkgconfig is NOT found in the 3rdparty prefix! This is normal only when builing pkgconfig itself.")
    endif()
endif()

message(STATUS "Using pkgconfig at: ${PKG_CONFIG_EXECUTABLE}")

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/meson-compiler.ini.in
    ${CMAKE_CURRENT_BINARY_DIR}/meson-compiler.ini
)

# Meson's CPU family is a bit different from what
# Android SDK exports as CMAKE_SYSTEM_PROCESSOR
set (MESON_CPU_FAMILY ${CMAKE_SYSTEM_PROCESSOR})
if (${MESON_CPU_FAMILY} STREQUAL "armv7-a")
    set(MESON_CPU_FAMILY "arm")
elseif (${MESON_CPU_FAMILY} STREQUAL "i686")
    set(MESON_CPU_FAMILY "x86")
endif()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/meson-host.ini.in
    ${CMAKE_CURRENT_BINARY_DIR}/meson-host.ini
)

# Prepare file for crosscompile multiple archs
if (CMAKE_OSX_ARCHITECTURES)
    foreach(arch ${CMAKE_OSX_ARCHITECTURES})
        mesonify(CROSS_COMPILE_FLAGS_${arch} _cross_compile_flags)
        configure_file(
            ${CMAKE_CURRENT_LIST_DIR}/meson-compiler.ini.in
            ${CMAKE_CURRENT_BINARY_DIR}/meson-compiler_${arch}.ini
        )
    endforeach()
endif()