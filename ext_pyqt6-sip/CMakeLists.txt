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
        URL https://files.pythonhosted.org/packages/90/24/a753e1af94b9ae5b2da63d4598457308da3cdbf0838c959381db086ccc86/pyqt6_sip-13.11.1.tar.gz
        URL_HASH SHA256=869c5b48afe38e55b1ee0dd72182b0886e968cc509b98023ff50010b013ce1be

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
        URL https://files.pythonhosted.org/packages/90/24/a753e1af94b9ae5b2da63d4598457308da3cdbf0838c959381db086ccc86/pyqt6_sip-13.11.1.tar.gz
        URL_HASH SHA256=869c5b48afe38e55b1ee0dd72182b0886e968cc509b98023ff50010b013ce1be

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""

        INSTALL_COMMAND 
            ${CMAKE_COMMAND} -E env
                PYTHONPATH=${_krita_pythonpath}
                # setuptools/_distutils/ccompiler.py expects MSVC to be the default compiler on
                # Windows, so we should pass a separate config file to actually switch it to
                # MinGW's one
                DIST_EXTRA_CONFIG=${CMAKE_CURRENT_SOURCE_DIR}/extra_distutils_mingw32_config.cfg
                ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                    -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR} -- <SOURCE_DIR> --prefix ${EXTPREFIX} --ignore-installed --verbose --no-deps --no-build-isolation
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_INSTALL_SCHEME}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_pyqt6-sip)