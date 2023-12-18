cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_pyqt5-sip)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

if(UNIX)
    ExternalProject_Add( ext_pyqt5-sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/P/PyQt5-sip/PyQt5_sip-12.11.0.tar.gz
        URL_HASH SHA256=b4710fd85b57edef716cc55fae45bfd5bfac6fc7ba91036f1dcc3f331ca0eb39

        CONFIGURE_COMMAND ""

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build ${_compiler} -j ${SUBMAKE_JOBS}

        # Here we need a flat-egg installation, otherwise the egg is deployed
        # inside its own directory in site-packages.
        # So we set as root our 3rdparty layout, and a sufficiently dud prefix.
        # See https://github.com/msys2/MINGW-packages/blob/8a4066591cf1e023971526c55bf2d5fe0c7aa84a/mingw-w64-pyqt5-sip/PKGBUILD
        # INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
        #     "PYTHONPATH=${KRITA_PYTHONPATH}"
        #     ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py install --prefix "." --root=${EXTPREFIX} --optimize=1
        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT=<SOURCE_DIR>/setup.py
                -P ${CMAKE_CURRENT_SOURCE_DIR}/run-python-setup-with-destdir.cmake -- --skip-build --prefix=${EXTPREFIX} --optimize=1
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_SHEBANG_LINES}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
elseif(WIN32)
    if(MINGW)
        set(_compiler -c mingw32)
        set(_make_command mingw32-make)
    elseif(MSVC)
        set(_compiler -c msvc)
        set(_make_command jom)
    endif()

    krita_to_native_path("${EXTPREFIX}" _pyqt_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add( ext_pyqt5-sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/P/PyQt5-sip/PyQt5_sip-12.11.0.tar.gz
        URL_HASH SHA256=b4710fd85b57edef716cc55fae45bfd5bfac6fc7ba91036f1dcc3f331ca0eb39

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-MinGW-Distutils-support-hack.patch

        CONFIGURE_COMMAND ""

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            SETUPTOOLS_USE_DISTUTILS=local
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build ${_compiler} -j ${SUBMAKE_JOBS}

        # Here we need a flat-egg installation, otherwise the egg is deployed
        # inside its own directory in site-packages.
        # So we set as root our 3rdparty layout, and a sufficiently dud prefix.
        # See https://github.com/msys2/MINGW-packages/blob/8a4066591cf1e023971526c55bf2d5fe0c7aa84a/mingw-w64-pyqt5-sip/PKGBUILD
        # INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
        #     PYTHONPATH=${_krita_pythonpath}
        #     SETUPTOOLS_USE_DISTUTILS=local
        #     ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py install --skip-build --prefix "." --root=${_pyqt_prefix} --optimize=1 --install-scripts=${_pyqt_prefix}\\bin

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env
            PYTHONPATH=${_krita_pythonpath}
            SETUPTOOLS_USE_DISTUTILS=local
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT=<SOURCE_DIR>/setup.py
                -P ${CMAKE_CURRENT_SOURCE_DIR}/run-python-setup-with-destdir.cmake -- --skip-build --prefix=${_pyqt_prefix} --optimize=1  --install-scripts=${_pyqt_prefix}\\bin --install-lib=${_pyqt_prefix}\\lib\\site-packages

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_pyqt5-sip)