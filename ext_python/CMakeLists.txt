cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_python)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (UNIX)
    if (APPLE)
        message (FATAL_ERROR "ext_python is not yet ported on MacOS!")

        if(MACOS_ARCHS GREATER 1)
            set(PYTHON_MACOS_CONFIG "--enable-universalsdk" "--with-universal-archs=universal2")
        endif()
        ExternalProject_Add( ext_python
            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
            URL https://www.python.org/ftp/python/3.10.7/Python-3.10.7.tar.xz
            URL_MD5 b8094f007b3a835ca3be6bdf8116cccc

            PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/osx_fixappinstall.diff

            # Setuptools needs OpenSSL 1.1, the stock libssl isn't enough
            CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
                PATH="${EXTPREFIX}/lib/Python.framework/Versions/Current/bin:$ENV{PATH}"
                <SOURCE_DIR>/configure MACOSX_DEPLOYMENT_TARGET=10.13 --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE} --with-openssl=${EXTPREFIX}
                --enable-framework=${EXTPREFIX}/lib --enable-optimizations --with-suffix=no
                ${PYTHON_MACOS_CONFIG}

            # force single-threaded installation to avoid race conditions
            INSTALL_COMMAND ${CMAKE_COMMAND} -E env
                PATH="${EXTPREFIX}/lib/Python.framework/Versions/Current/bin:$ENV{PATH}"
                make -j1 install

            UPDATE_COMMAND ""

            DEPENDS ext_openssl
        )
        ExternalProject_Add_Step( ext_python create_symlink
            COMMENT "Creating helper symlinks"
            COMMAND ${CMAKE_COMMAND} -E copy ${EXTPREFIX}/bin/python3 ${EXTPREFIX}/bin/python
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/sitecustomize.py ${EXTPREFIX}/lib/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${EXTPREFIX}/lib/Python.framework/Versions/Current/lib/python${PYTHON_VERSION} ${EXTPREFIX}/lib/python${PYTHON_VERSION}
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${EXTPREFIX}/lib/Python.framework/Versions/Current/include/python${PYTHON_VERSION} ${EXTPREFIX}/include/python${PYTHON_VERSION}
            COMMAND ${CMAKE_COMMAND} -E create_symlink ./lib/python${PYTHON_VERSION}/site-packages ${EXTPREFIX}/lib/Python.framework/Versions/Current/site-packages
            # CMake FindPythonLib can't find framework libraries, lack of maintainer for Python
            COMMAND find ${EXTPREFIX}/lib/Python.framework/Versions/Current/lib -type l -d 1
            | grep -o "[^/]*$"
            | xargs -I FILE ${CMAKE_COMMAND} -E create_symlink ./Python.framework/Python ${EXTPREFIX}/lib/FILE
            DEPENDEES install
        )
        ExternalProject_Add_Step( ext_python update_sip
            COMMENT "Updating pip"
            COMMAND COMMAND ${EXTPREFIX}/bin/python3 -m pip install --upgrade pip
            DEPENDEES install
        )
        # TODO: modify krita_add_to_ci_targets to use other targets, not normal install!
        ExternalProject_Add_Step( ext_python update_certifi
            COMMENT "Deploying certifi to our OpenSSL CApath"
            COMMAND ${EXTPREFIX}/bin/python3 ${CMAKE_CURRENT_SOURCE_DIR}/install_certificates.py
            DEPENDEES update_sip
        )

        message(FATAL_ERROR "TODO: configure targets with krita_add_to_ci_targets")

    else()

    if (ANDROID)
        message (FATAL_ERROR "TODO: the build of Python on Android is not implemented! It should use --with-openssl=${EXTPREFIX} to use proper openssl")
    endif()

    ExternalProject_Add( ext_python
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.python.org/ftp/python/3.10.7/Python-3.10.7.tar.xz
        URL_MD5 b8094f007b3a835ca3be6bdf8116cccc

        CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE} --enable-shared

        UPDATE_COMMAND ""
    )

    ExternalProject_Add_Step( 
        ext_python 
        pre_install
        # presumably something actually needs this symlink?
        COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink python3.10 python
        COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/python -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}

        DEPENDERS install
    )
    
    krita_add_to_ci_targets(ext_python)

    endif()
elseif(WIN32)
    ExternalProject_Add( ext_python
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.python.org/ftp/python/3.10.7/python-3.10.7-embed-amd64.zip
        URL_MD5 7f90f8642c1b19cf02bce91a5f4f9263

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo deploying python3 64-bit binary
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/ -DDST=${EXTPREFIX}/python -P ${KRITA_CI_INSTALL_DIRECTORY}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/python3.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/python310.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/vcruntime140.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/vcruntime140_1.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/sitecustomize.py -DDST=${EXTPREFIX}/lib/site-packages/ -P  ${KRITA_CI_INSTALL}
                # we install _distutils_system_mod.py on Windows only!
                COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/_distutils_system_mod.py -DDST=${EXTPREFIX}/lib/site-packages/ -P  ${KRITA_CI_INSTALL}
        UPDATE_COMMAND ""
    )

    krita_add_to_ci_targets(ext_python)
endif()
