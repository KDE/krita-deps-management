

execute_process(COMMAND arch OUTPUT_VARIABLE ARCH_OUTPUT)

# for testing outside macOS uncomment the following line
# execute_process(COMMAND echo " arm64  " OUTPUT_VARIABLE ARCH_OUTPUT)

string(STRIP "${ARCH_OUTPUT}" ARCH_OUTPUT)

message(STATUS "MacOS Arch returned: ${ARCH_OUTPUT}")

if ("${ARCH_OUTPUT}" STREQUAL "arm64")
    set (CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "List of architectures for building macOS fat binaries")
endif()

message(STATUS "Target fat binary architectures: ${CMAKE_OSX_ARCHITECTURES}")

if (NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
    message(FATAL_ERROR "MACOSX_DEPLOYMENT_TARGET environment variable is not set!")
endif()

# it seems like the usage of a toolchain file resets cmake's ability
# to initialize CMAKE_PREFIX_PATH from an environment variable, so
# we should set it up manually
if (DEFINED ENV{CMAKE_PREFIX_PATH})
    set(CMAKE_PREFIX_PATH $ENV{CMAKE_PREFIX_PATH})
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "$ENV{MACOSX_DEPLOYMENT_TARGET}")
