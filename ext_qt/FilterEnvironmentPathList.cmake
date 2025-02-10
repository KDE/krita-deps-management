function(filter_environment_path_list var prefix result)
    # Read the environment variable into a list
    set(native_path_list "$ENV{${var}}")

    # Convert to CMake path list
    cmake_path(CONVERT "${native_path_list}" TO_CMAKE_PATH_LIST cmake_path_list NORMALIZE)
    set(filtered_list "")

    # Iterate through the path list
    foreach(current_path IN LISTS cmake_path_list)
        cmake_path(IS_PREFIX prefix "${current_path}" NORMALIZE is_prefix)
        if(NOT is_prefix)
            list(APPEND filtered_list "${current_path}")
        endif()
    endforeach()

    # Convert filtered list back to native path separators
    cmake_path(CONVERT "${filtered_list}" TO_NATIVE_PATH_LIST native_path_list)
    if(NOT WIN32)
        set(${result} ${native_path_list} PARENT_SCOPE)
    else()
        string(REPLACE ";" "$<SEMICOLON>" masked_native_path_list "${native_path_list}")
        set(${result} ${masked_native_path_list} PARENT_SCOPE)
    endif()
endfunction()

# filter_environment_path_list("PATH" "/home/appimage/persistent/deps/krita-deps-management/ext_qt/_install" myresult)
# message(STATUS "Result: ${myresult}")