if (NOT MAKE_COMMAND) 
    message(FATAL_ERROR "${MAKE_COMMAND} is not defined!")
endif()

if (DEFINED ENV{DESTDIR})
    set(DESTDIR $ENV{DESTDIR})
    cmake_path(ABSOLUTE_PATH DESTDIR NORMALIZE)

    if (WIN32)
        # Qt's makefiles add 'C:' prefix internally, so remove it
        cmake_path(GET DESTDIR RELATIVE_PART RELATIVE_DESTDIR)
        cmake_path(NATIVE_PATH RELATIVE_DESTDIR NATIVE_RELATIVE_DESTDIR)
        set(DESTDIR_ARGS "INSTALL_ROOT=\\${NATIVE_RELATIVE_DESTDIR}")
    else()
        set(DESTDIR_ARGS "INSTALL_ROOT=${DESTDIR}")
    endif()

endif()

# message(STATUS "DESTDIR_ARGS=${DESTDIR_ARGS}")

foreach(i RANGE 0 ${CMAKE_ARGC})
    if ("${CMAKE_ARGV${i}}" STREQUAL "--")
        set(FOUND_SEPARATOR TRUE)
    elseif (FOUND_SEPARATOR)
        list(APPEND EXTRA_ARGS ${CMAKE_ARGV${i}})
    endif()
endforeach()

exec_program(${MAKE_COMMAND} ARGS ${DESTDIR_ARGS} ${EXTRA_ARGS})