# A script that automatically handles $ENV{DESTDIR} forwarding
#
# Usage:
# ${CMAKE_COMMAND} -DSRC=bin/patch.exe -DDST=${EXTPREFIX} -P ${CMAKE_SOURCE_DIR}/cmake/install_custom.cmake
#

file(INSTALL ${SRC} DESTINATION ${DST})