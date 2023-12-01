# A script that automatically handles $ENV{DESTDIR} forwarding
#
# Usage:
# ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${EXTPREFIX}/bin -P ${CMAKE_SOURCE_DIR}/cmake/install_directory_custom.cmake
#

file(GLOB ALL_SUBDIRS "${SRC}/*")
foreach (SUBDIR ${ALL_SUBDIRS})
    file(INSTALL ${SUBDIR} DESTINATION ${PREFIX})
endforeach()

