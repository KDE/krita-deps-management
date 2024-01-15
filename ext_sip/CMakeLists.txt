cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_sip)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

message (STATUS "python executable: ${Python_EXECUTABLE}")

if(UNIX)
    ExternalProject_Add( ext_sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/s/sip/sip-6.6.2.tar.gz
        URL_HASH SHA256=0e3efac1c5dfd8e525ae57140927df26993e13f58b89d1577c314f4105bfd90d

        CONFIGURE_COMMAND ""

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build -j ${SUBMAKE_JOBS}

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT=<SOURCE_DIR>/setup.py
                -P ${KRITA_CI_RUN_SETUP_PY_WITH_DESTDIR} -- --skip-build --prefix=${EXTPREFIX} --optimize=1
            COMMAND ${CMAKE_COMMAND} -DPREFIX=${EXTPREFIX} -P ${KRITA_CI_FIX_PYTHON_SHEBANG_LINES}

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
elseif (WIN32)
    if(MINGW)
        set(_compiler -c mingw32)
    elseif(MSVC)
        set(_compiler -c msvc)
    endif()

    if (NOT EXISTS "${EXTPREFIX}/lib/site-packages/sitecustomize.py")
        message(FATAL_ERROR "sitecustomize.py file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/lib/site-packages/sitecustomize.py)")
    endif()

    if (NOT EXISTS "${EXTPREFIX}/lib/site-packages/_distutils_system_mod.py")
        message(FATAL_ERROR "_distutils_system_mod.py file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/lib/site-packages/_distutils_system_mod.py)")
    endif()

    if (NOT EXISTS "${EXTPREFIX}/bin/python3.dll")
        message(FATAL_ERROR "python3.dll file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/bin/python3.dll)")
    endif()

    #
    # On Windows we don't install/build Python ourselves, hence we should make sure that the
    # user installed all the necessary tools in advance
    #
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
                ${Python_EXECUTABLE} -m pip show setuptools
        RESULT_VARIABLE PIP_RESULT
        OUTPUT_VARIABLE PIP_OUTPUT
        ECHO_OUTPUT_VARIABLE
        COMMAND_ECHO STDOUT
        )

    if (NOT PIP_RESULT EQUAL 0)
        message(FATAL_ERROR "failed to fetch information about setuptools version")
    endif()

    if (${PIP_OUTPUT} MATCHES "Version: ([0-9\.]+)") 
        set(SETUPTOOLS_VERSION ${CMAKE_MATCH_1})
        message(STATUS "Found \'setuptools\' python module: ${SETUPTOOLS_VERSION}")
    else()
        message(FATAL_ERROR "failed to parse setuptools version returned by pip")
    endif()

    if (${SETUPTOOLS_VERSION} VERSION_LESS "59.8.0")
        message(FATAL_ERROR "setuptools python module is too old!")
    endif()

    krita_to_native_path("${EXTPREFIX}" _sip_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add( ext_sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/s/sip/sip-6.6.2.tar.gz
        URL_HASH SHA256=0e3efac1c5dfd8e525ae57140927df26993e13f58b89d1577c314f4105bfd90d

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-distinfo.py-to-support-prefix-option-on-Windows-.patch

        CONFIGURE_COMMAND ""

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            SETUPTOOLS_USE_DISTUTILS=local
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build -j ${SUBMAKE_JOBS} ${_compiler}

        # HACK: Create lib\site-packages before installing
        # See e.g. https://access.redhat.com/errata/RHBA-2020:4437
        INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${EXTPREFIX}/lib/site-packages
            COMMAND ${CMAKE_COMMAND} -E env    
                PYTHONPATH=${_krita_pythonpath}
                SETUPTOOLS_USE_DISTUTILS=local
                ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT=<SOURCE_DIR>/setup.py
                    -P ${KRITA_CI_RUN_SETUP_PY_WITH_DESTDIR} -- --skip-build --prefix=${_sip_prefix} --optimize=1  --install-scripts=${_sip_prefix}\\bin --install-lib=${_sip_prefix}\\lib\\site-packages

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_sip)