function (find_cmake_like_prefix all_args OUTPUT_VARIABLE)
    foreach(arg ${all_args})
        if (arg MATCHES "^-DCMAKE_INSTALL_PREFIX=.+")
            string(REGEX REPLACE "^(-DCMAKE_INSTALL_PREFIX=)(.+)" "\\2" prefix ${arg})
            set (${OUTPUT_VARIABLE} ${prefix} PARENT_SCOPE)
            break()
        endif ()
    endforeach()
endfunction()

function (find_cmake_like_prefix_string arguments_string OUTPUT_VARIABLE)
    separate_arguments(all_args UNIX_COMMAND "${arguments_string}")
    find_cmake_like_prefix("${all_args}" prefix)
    set (${OUTPUT_VARIABLE} ${prefix} PARENT_SCOPE)
endfunction()


# testing code:
#find_cmake_like_prefix_string("--foo -DBUILD_TESTING=ON -DCMAKE_INSTALL_PREFIX=/home/devel -b something" prefix)
#message(STATUS "Found prefix: ${prefix}")
