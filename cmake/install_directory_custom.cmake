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

file(GLOB ALL_SUBDIRS "${SRC}/*")
foreach (SUBDIR ${ALL_SUBDIRS})
    file(INSTALL ${SUBDIR} DESTINATION ${PREFIX})
endforeach()

