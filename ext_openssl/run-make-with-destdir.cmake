if (DEFINED ENV{DESTDIR})
    set(DESTDIR_ARGS "DESTDIR=$ENV{DESTDIR}")
endif()

exec_program(make ARGS ${DESTDIR_ARGS} ${ARGS})