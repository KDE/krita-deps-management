
function (offset_prefix_with_destdir DESTDIR PREFIX OUTPUT_VARIABLE)
    cmake_path(IS_ABSOLUTE PREFIX PREFIX_IS_ABSOLUTE)
    if (NOT PREFIX_IS_ABSOLUTE)
        cmake_path(ABSOLUTE_PATH PREFIX NORMALIZE)
    endif()

    cmake_path(GET PREFIX ROOT_PATH ROOT_COMPONENT)
    cmake_path(RELATIVE_PATH PREFIX BASE_DIRECTORY ${ROOT_COMPONENT})
    cmake_path(APPEND DESTDIR ${PREFIX})

    set (${OUTPUT_VARIABLE} ${DESTDIR} PARENT_SCOPE)
endfunction()


# testing code:

# set(DESTDIR "/home/appimage/persistent/krita/krita-deps-management/ext_fribidi/_build/ext_fribidi-prefix/tmp/build_uni")
# set(PREFIX "/home/appimage/persistent/krita/krita-deps-management/ext_fribidi/_install")
# offset_prefix_with_destdir(${DESTDIR} ${PREFIX} RESULT)
# message(STATUS "Result: ${RESULT}")
