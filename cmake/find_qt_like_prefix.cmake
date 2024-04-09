function (find_qt_like_prefix all_args OUTPUT_VARIABLE)
    set(take_next_arg OFF)
    
    foreach(arg ${all_args})
        if (take_next_arg) 
            set (${OUTPUT_VARIABLE} ${arg} PARENT_SCOPE)
            break()
        endif()

        if (arg STREQUAL "-prefix") 
            set(take_next_arg ON)
        endif ()
    endforeach()
endfunction()

function (find_qt_like_prefix_string arguments_string OUTPUT_VARIABLE)
    string(REPLACE " " ";" arguments_string ${arguments_string})
    find_qt_like_prefix("${arguments_string}" prefix)
    set (${OUTPUT_VARIABLE} ${prefix} PARENT_SCOPE)
endfunction()


# testing code:
# find_qt_like_prefix_string("--foo -prefix /home/devel -b something" prefix)
# message(STATUS "Found prefix: ${prefix}")