cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_pyqt-builder)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

if(UNIX)
    ExternalProject_Add(ext_pyqt-builder
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.pythonhosted.org/packages/0b/0a/e7684c054c3b85999354bb3be7ccbd6e6d9b751940cec8ecff5e7a8ea9f7/pyqt_builder-1.18.1.tar.gz
        URL_HASH SHA256=3f7a3a2715947a293a97530a76fd59f1309fcb8e57a5830f45c79fe7249b3998

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR} -- <SOURCE_DIR> --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_SHEBANG_LINES}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
elseif(WIN32)
    if(MINGW)
        set(_make_command mingw32-make)
    elseif(MSVC)
        set(_make_command jom)
    endif()

    krita_to_native_path("${EXTPREFIX}" _pyqt_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add(ext_pyqt-builder
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.pythonhosted.org/packages/0b/0a/e7684c054c3b85999354bb3be7ccbd6e6d9b751940cec8ecff5e7a8ea9f7/pyqt_builder-1.18.1.tar.gz
        URL_HASH SHA256=3f7a3a2715947a293a97530a76fd59f1309fcb8e57a5830f45c79fe7249b3998

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-support-for-MinGW-builds.patch

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""

        INSTALL_COMMAND 
            ${CMAKE_COMMAND} -E env 
                PYTHONPATH=${_krita_pythonpath}
                ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                    -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR} -- <SOURCE_DIR> --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_INSTALL_SCHEME}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )

endif()

krita_add_to_ci_targets(ext_pyqt-builder)