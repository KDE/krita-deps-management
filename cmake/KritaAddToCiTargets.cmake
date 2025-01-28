function (krita_add_to_ci_targets ext_target)
    if (NOT TARGET ext_build)
        add_custom_target(ext_build)
    endif()
    add_dependencies(ext_build ${ext_target}-build)

    if (NOT TARGET ext_install)
        add_custom_target(ext_install)
    endif()
    add_dependencies(ext_install ${ext_target}-install)
endfunction()