
cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_strawberryperl)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (NOT WIN32)
    message (FATAL_ERROR "ext_strawberryperl in supported on Windows only")
endif()

ExternalProject_Add(
    ext_strawberryperl
    DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
    # From https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-32bit-portable.zip
    URL https://files.kde.org/krita/build/dependencies/strawberry-perl-5.32.1.1-32bit-portable.zip
    URL_HASH SHA1=28bca91cadd6651c2b2463db8587c170bf17f2fa

    BUILD_COMMAND ""
    CONFIGURE_COMMAND ""
    INSTALL_COMMAND
                ${CMAKE_COMMAND} -E echo Deploying Strawberry Perl portable
        COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${EXTPREFIX}/Strawberry -P ${KRITA_CI_INSTALL_DIRECTORY}
        COMMAND ${CMAKE_COMMAND} -E echo "Removing Strawberry Perl pkg-config"
        COMMAND ${CMAKE_COMMAND} -DSRC=Strawberry/perl/bin/pkg-config.bat -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_REMOVE_AT_PREFIX}
        COMMAND ${CMAKE_COMMAND} -DSRC=Strawberry/perl/bin/pkg-config -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_REMOVE_AT_PREFIX}

        UPDATE_COMMAND ""

    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Strawberry"
)

# set(USE_STRAWBERRYPERL ON CACHE BOOL "Krita will use its own package of strawberryperl" FORCE)
# set(PERL_EXECUTABLE ${EXTPREFIX}/Strawberry/perl/bin/perl.exe CACHE FILEPATH "Path to our own perl executable" FORCE)
# string(TOLOWER "$ENV{PATH}" _path)
# if (NOT _path MATCHES "strawberry")
#     message(FATAL_ERROR "Please add the following directories to PATH: ${EXTPREFIX}\\Strawberry\\perl\\bin")
# else()
#     message(STATUS "Perl not found, using Strawberry Perl as a fallback.")
# endif()

krita_add_to_ci_targets(ext_strawberryperl)