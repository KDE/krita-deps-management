cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_meson)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

if (WIN32)
    krita_to_native_path("${EXTPREFIX}" _meson_prefix)

    ExternalProject_Add( ext_meson
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/mesonbuild/meson/releases/download/1.7.2/meson-1.7.2.tar.gz
        URL_HASH SHA256=4d40d63aa748a9c139cc41ab9bffe43edd113c5639d78bde81544ca955aea890

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR}  -- <SOURCE_DIR> --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_INSTALL_SCHEME}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )

elseif(NOT CMAKE_CROSSCOMPILING)
    set(_meson_prefix "${EXTPREFIX}")

    ExternalProject_Add( ext_meson
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/mesonbuild/meson/releases/download/1.7.2/meson-1.7.2.tar.gz
        URL_HASH SHA256=4d40d63aa748a9c139cc41ab9bffe43edd113c5639d78bde81544ca955aea890

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR}  -- <SOURCE_DIR> --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_SHEBANG_LINES}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
else()
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)
    
    # Meson needs to be brought manually when crosscompiling.
    ExternalProject_Add(ext_meson
        DOWNLOAD_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND 
            ${CMAKE_COMMAND} -E env 
                PYTHONPATH=${_krita_pythonpath}
                ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                    -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR} -- --upgrade meson==1.7.2 --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
                    COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_SHEBANG_LINES}
                    COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_INSTALL_SCHEME}

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_meson)