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
        URL https://files.pythonhosted.org/packages/62/9a/78122735697dbfc6c1db363627309eb0da7e44d8c05ba017b08666530586/sip-6.10.0.tar.gz
        URL_HASH SHA256=fa0515697d4c98dbe04d9e898d816de1427e5b9ae5d0e152169109fd21f5d29c

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
elseif (WIN32)
    if (NOT EXISTS "${EXTPREFIX}/lib/site-packages/sitecustomize.py")
        message(FATAL_ERROR "sitecustomize.py file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/lib/site-packages/sitecustomize.py)")
    endif()

    if (NOT EXISTS "${EXTPREFIX}/lib/site-packages/_distutils_system_mod.py")
        message(FATAL_ERROR "_distutils_system_mod.py file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/lib/site-packages/_distutils_system_mod.py)")
    endif()

    if (NOT EXISTS "${EXTPREFIX}/bin/python3.dll")
        message(FATAL_ERROR "python3.dll file is not found! Make sure you have installed necessary Krita's python package (expected location: ${EXTPREFIX}/bin/python3.dll)")
    endif()

    krita_to_native_path("${EXTPREFIX}" _sip_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add( ext_sip
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://files.pythonhosted.org/packages/62/9a/78122735697dbfc6c1db363627309eb0da7e44d8c05ba017b08666530586/sip-6.10.0.tar.gz
        URL_HASH SHA256=fa0515697d4c98dbe04d9e898d816de1427e5b9ae5d0e152169109fd21f5d29c

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-distinfo.py-to-support-prefix-option-on-Windows-.patch

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

krita_add_to_ci_targets(ext_sip)