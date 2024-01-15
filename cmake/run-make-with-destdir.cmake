if (DEFINED ENV{DESTDIR})
    set(DESTDIR_ARGS "DESTDIR=$ENV{DESTDIR}")
endif()

exec_program(make ARGS ${DESTDIR_ARGS} ${ARGS} RETURN_VALUE RETVAL)
if (RETVAL)
    message(FATAL_ERROR "failed to execute make")
endif()