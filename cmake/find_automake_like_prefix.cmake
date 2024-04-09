function (find_automake_like_prefix all_args OUTPUT_VARIABLE)
    foreach(arg ${all_args})
    message(${arg})
        if (arg MATCHES "^--prefix=.+") 
            string(REGEX REPLACE "^(--prefix=)(.+)" "\\2" prefix ${arg})
            set (${OUTPUT_VARIABLE} ${prefix} PARENT_SCOPE)
            break()
        endif ()
    endforeach()
endfunction()

function (find_automake_like_prefix_string arguments_string OUTPUT_VARIABLE)
    find_automake_like_prefix(${arguments_string} prefix)
    set (${OUTPUT_VARIABLE} ${prefix} PARENT_SCOPE)
endfunction()


# testing code:
# find_automake_like_prefix_string("--foo --prefix=/home/devel -b something" prefix)
# message(STATUS "Found prefix: ${prefix}")