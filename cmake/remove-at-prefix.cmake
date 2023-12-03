#
# Usage: cmake -DSRC=path/relative/to/prefix/foo.bar -DPREFIX=/prefix/path -P remove-at-prefix.cmake
#

if (DEFINED ENV{DESTDIR})
    set(DESTDIR $ENV{DESTDIR})
    cmake_path(ABSOLUTE_PATH PREFIX NORMALIZE)
    cmake_path(ABSOLUTE_PATH DESTDIR NORMALIZE)

    cmake_path(GET PREFIX RELATIVE_PART RELATIVE_PREFIX)
    # message("prefix ${PREFIX}")
    # message("relprefix ${RELATIVE_PREFIX}")

    cmake_path(APPEND NEWPREFIX ${DESTDIR} ${RELATIVE_PREFIX})
    set(PREFIX ${NEWPREFIX})
    # message("finalprefix ${PREFIX}")
endif()

cmake_path(APPEND REAL_FILE ${PREFIX} ${SRC})

message ("Removing: ${REAL_FILE}")

exec_program(${CMAKE_COMMAND} ARGS -E rm -r ${REAL_FILE})
