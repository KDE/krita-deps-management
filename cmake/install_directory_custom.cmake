# A script that automatically handles $ENV{DESTDIR} forwarding
#
# Usage:
# ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${EXTPREFIX}/bin -P ${CMAKE_SOURCE_DIR}/cmake/install_directory_custom.cmake
#

if (NOT EXISTS ${SRC})
    message(FATAL_ERROR "Remove: Cannot file the source path: \"${SRC}\"")
endif()

file(GLOB ALL_SUBDIRS "${SRC}/*")
foreach (SUBDIR ${ALL_SUBDIRS})
    file(INSTALL ${SUBDIR} DESTINATION ${DST} USE_SOURCE_PERMISSIONS)
endforeach()

