LIST (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../cmake/kde_macro")
include (KritaToNativePath)

if (DEFINED ENV{DESTDIR})
    set(DESTDIR $ENV{DESTDIR})
    cmake_path(ABSOLUTE_PATH DESTDIR NORMALIZE)
    krita_to_native_path("${DESTDIR}" DESTDIR)

    set(DESTDIR_ARGS "--root=${DESTDIR}")
endif()

set(FOUND_SEPARATOR FALSE)

foreach(i RANGE 0 ${CMAKE_ARGC})
    if ("${CMAKE_ARGV${i}}" STREQUAL "--")
        set(FOUND_SEPARATOR TRUE)
    elseif (FOUND_SEPARATOR)
        list(APPEND EXTRA_ARGS ${CMAKE_ARGV${i}})
    endif()
endforeach()

# message("extra args: ${EXTRA_ARGS}")

message ("Running setup with args: ${Python_EXECUTABLE} ${SCRIPT} install ${DESTDIR_ARGS} ${EXTRA_DESTDIR_ARGS} ${EXTRA_ARGS}")

exec_program(${Python_EXECUTABLE} ARGS ${SCRIPT} install ${DESTDIR_ARGS} ${EXTRA_ARGS} RETURN_VALUE RETVAL)
if (RETVAL)
    message(FATAL_ERROR "failed to execute the setup script")
endif()