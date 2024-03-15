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

if (NOT DEFINED B2_COMMAND)
    if(WIN32)
        set(B2_COMMAND "b2")
    else()
        set(B2_COMMAND "./b2")
    endif()
endif()

if (LAZY_CREATE_PREFIX AND NOT EXISTS ${PREFIX})
    if (EXISTS ${PREFIX} AND NOT IS_DIRECTORY ${PREFIX})
        message (FATAL_ERROR "Prefix path exists, but not a directory! (${PREFIX})")
    endif()

    file(MAKE_DIRECTORY ${PREFIX})
endif ()

set(FOUND_SEPARATOR FALSE)

foreach(i RANGE 0 ${CMAKE_ARGC})
    if ("${CMAKE_ARGV${i}}" STREQUAL "--")
        set(FOUND_SEPARATOR TRUE)
    elseif (FOUND_SEPARATOR)
        list(APPEND EXTRA_ARGS ${CMAKE_ARGV${i}})
    endif()
endforeach()

# message("extra args: ${EXTRA_ARGS}")

message ("Running b2 with args: --prefix=${PREFIX} ${EXTRA_ARGS}")

exec_program(${B2_COMMAND} ARGS --prefix=${PREFIX} ${EXTRA_ARGS} RETURN_VALUE RETVAL)
if (RETVAL)
    message(FATAL_ERROR "failed to run b2")
endif()