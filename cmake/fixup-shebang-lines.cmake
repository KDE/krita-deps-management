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

file(GLOB ALL_BINARIES "${PREFIX}/bin/*")
foreach (FILE ${ALL_BINARIES})
    file (READ ${FILE} _shebang LIMIT "2")

    if (_shebang MATCHES "#!")
        file (STRINGS ${FILE} _shebang LIMIT_COUNT "1")

        if (_shebang MATCHES "#!.*python[0-9.]*$" AND NOT _shebang MATCHES "#!/usr/bin/env python3$")
            message(STATUS "Fixing shebang line in file: ${FILE}")
            message(STATUS "    \"${_shebang}\" -> \"#!/usr/bin/env python3\"")

            file (READ ${FILE} _full_file)
            string(REGEX REPLACE "^(#!.*python[0-9.]*)\n" "#!/usr/bin/env python3\n" _out ${_full_file})
            file (WRITE ${FILE} ${_out})
        endif()

    endif()
endforeach()