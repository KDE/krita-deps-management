# A script that automatically handles $ENV{DESTDIR} forwarding
#
# Usage:
# ${CMAKE_COMMAND} -DSRC=bin/patch.exe -DPREFIX=${EXTPREFIX} -DDST=bin/patch.exe -P ${CMAKE_SOURCE_DIR}/../cmake/install_custom.cmake
#

if (NOT DST)
    set(DST ${SRC})
endif()

cmake_path(GET DST PARENT_PATH DST_PREFIX)
cmake_path(APPEND PREFIX ${DST_PREFIX})

file(INSTALL ${SRC} DESTINATION ${PREFIX})