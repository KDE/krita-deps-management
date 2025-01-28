# A script that automatically handles $ENV{DESTDIR} forwarding
#
# Usage:
# ${CMAKE_COMMAND} -DSRC=bin/patch.exe -DDST=${EXTPREFIX} -P ${CMAKE_SOURCE_DIR}/cmake/install_custom.cmake
#

if (RENAME)
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/_krita-tmp/)
    file(COPY_FILE ${SRC} ${CMAKE_CURRENT_BINARY_DIR}/_krita-tmp/${RENAME})
    file(INSTALL ${CMAKE_CURRENT_BINARY_DIR}/_krita-tmp/${RENAME} DESTINATION ${DST})
    file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/_krita-tmp/)
else()
    file(INSTALL ${SRC} DESTINATION ${DST})
endif()
