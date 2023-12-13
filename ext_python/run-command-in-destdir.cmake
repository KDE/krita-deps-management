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

set(FOUND_SEPARATOR FALSE)

foreach(i RANGE 0 ${CMAKE_ARGC})
    if ("${CMAKE_ARGV${i}}" STREQUAL "--")
        set(FOUND_SEPARATOR TRUE)
    elseif (FOUND_SEPARATOR)
        list(APPEND EXTRA_ARGS ${CMAKE_ARGV${i}})
    endif()
endforeach()

message ("Running ${PREFIX}/${COMMAND} with args: ${EXTRA_ARGS}")

exec_program(${PREFIX}/${COMMAND} ARGS ${EXTRA_ARGS})
