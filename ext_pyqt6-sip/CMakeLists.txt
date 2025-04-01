cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_pyqt6-sip)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

if(UNIX)
    ExternalProject_Add( ext_pyqt6-sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.pythonhosted.org/packages/90/18/0405c54acba0c8e276dd6f0601890e6e735198218d031a6646104870fe22/pyqt6_sip-13.10.0.tar.gz
        URL_HASH SHA256=d6daa95a0bd315d9ec523b549e0ce97455f61ded65d5eafecd83ed2aa4ae5350

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
    krita_to_native_path("${EXTPREFIX}" _pyqt_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add( ext_pyqt6-sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.pythonhosted.org/packages/90/18/0405c54acba0c8e276dd6f0601890e6e735198218d031a6646104870fe22/pyqt6_sip-13.10.0.tar.gz
        URL_HASH SHA256=d6daa95a0bd315d9ec523b549e0ce97455f61ded65d5eafecd83ed2aa4ae5350

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

krita_add_to_ci_targets(ext_pyqt6-sip)