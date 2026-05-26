cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_python)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (UNIX)
    if (APPLE)
        set(PYTHON_SHORT_VERSION "3.13")
        set(PYTHON_VERSION "3.13.5")

        if(MACOS_ARCHS GREATER 1)
            set(PYTHON_MACOS_CONFIG "--enable-universalsdk" "--with-universal-archs=universal2")
        endif()
        
        ExternalProject_Add( ext_python
            DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
            URL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
            URL_MD5 dbaa8833aa736eddbb18a6a6ae0c10fa

            PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-make-links-relative.patch
                  COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-adjusting-scripts-shebangs-for-relocatable-installs.patch

            # Setuptools needs OpenSSL 1.1, the stock libssl isn't enough
            CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
                PATH="${EXTPREFIX}/lib/Python.framework/Versions/Current/bin:$ENV{PATH}"
                # on MacOS we should use `-headerpad_max_install_names` so that clang would reserve enough space in the headers section;
                # otherwise, after we adjust rpath using post-install scripts, there will not be enough space for code signatures
                LDFLAGS=-headerpad_max_install_names
                <SOURCE_DIR>/configure MACOSX_DEPLOYMENT_TARGET=$ENV{MACOSX_DEPLOYMENT_TARGET} --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE}
                --with-openssl=${EXTPREFIX} --with-openssl-rpath=${EXTPREFIX}/lib
                --enable-framework=${EXTPREFIX}/lib --enable-optimizations --with-suffix=no --without-static-libpython
                ${PYTHON_MACOS_CONFIG}

            UPDATE_COMMAND ""

        )

        ExternalProject_Add_Step( ext_python create_symlink
            COMMENT "Creating helper symlinks"
            COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink python3 python
            COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/python -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
            
            COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink ./Python.framework/Python libpython${PYTHON_SHORT_VERSION}.dylib
            COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/libpython${PYTHON_SHORT_VERSION}.dylib -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}
            COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/sitecustomize.py -DDST=${EXTPREFIX}/lib/Python.framework/Versions/${PYTHON_SHORT_VERSION}/lib/python${PYTHON_SHORT_VERSION}/ -P ${KRITA_CI_INSTALL}

            COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink ./Python.framework/Versions/${PYTHON_SHORT_VERSION}/lib/python${PYTHON_SHORT_VERSION} python${PYTHON_SHORT_VERSION}
            COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/python${PYTHON_SHORT_VERSION} -DDST=${EXTPREFIX}/lib -P ${KRITA_CI_INSTALL}

            COMMAND ${CMAKE_COMMAND} -E make_directory <TMP_DIR>/include
            COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR>/include ${CMAKE_COMMAND} -E create_symlink ../lib/Python.framework/Versions/${PYTHON_SHORT_VERSION}/include/python${PYTHON_SHORT_VERSION} python${PYTHON_SHORT_VERSION}
            COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/include/python${PYTHON_SHORT_VERSION} -DDST=${EXTPREFIX}/include -P ${KRITA_CI_INSTALL}

            COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink ./lib/python${PYTHON_SHORT_VERSION}/site-packages site-packages
            COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/site-packages -DDST=${EXTPREFIX}/lib/Python.framework/Versions/${PYTHON_SHORT_VERSION}/ -P ${KRITA_CI_INSTALL}
            
            DEPENDERS install
        )
        # TODO: modify krita_add_to_ci_targets to use other targets, not normal install!
        # ExternalProject_Add_Step( ext_python update_certifi
        #     COMMENT "Deploying certifi to our OpenSSL CApath"
        #     COMMAND ${EXTPREFIX}/bin/python3 ${CMAKE_CURRENT_SOURCE_DIR}/install_certificates.py
        #     DEPENDS install
        # )

        if (NOT TARGET ext_install)
            add_custom_target(ext_install)
        endif()

        krita_add_to_ci_targets(ext_python)

    else()

    if (ANDROID)
        message (FATAL_ERROR "TODO: the build of Python on Android is not implemented! It should use --with-openssl=${EXTPREFIX} to use proper openssl")
    endif()

    ExternalProject_Add( ext_python
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.python.org/ftp/python/3.13.5/Python-3.13.5.tar.xz
        URL_MD5 dbaa8833aa736eddbb18a6a6ae0c10fa

        CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTPREFIX} ${GLOBAL_AUTOMAKE_PROFILE} --enable-shared --without-static-libpython

        UPDATE_COMMAND ""
    )

    ExternalProject_Add_Step( 
        ext_python 
        pre_install
        # presumably something actually needs this symlink?
        COMMAND ${CMAKE_COMMAND} -E chdir <TMP_DIR> ${CMAKE_COMMAND} -E create_symlink python3.13 python
        COMMAND ${CMAKE_COMMAND} -DSRC=<TMP_DIR>/python -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}

        DEPENDERS install
    )
    
    krita_add_to_ci_targets(ext_python)

    endif()
elseif(WIN32)
    ExternalProject_Add( ext_python
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://www.python.org/ftp/python/3.13.5/python-3.13.5-embed-amd64.zip
        URL_MD5 370a345dbea8bbc1830a2385f24632d2

        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo deploying python3 64-bit binary
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/ -DDST=${EXTPREFIX}/python -P ${KRITA_CI_INSTALL_DIRECTORY}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/python3.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/python313.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/vcruntime140.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/vcruntime140_1.dll -DDST=${EXTPREFIX}/bin -P  ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/sitecustomize.py -DDST=${EXTPREFIX}/lib/site-packages/ -P  ${KRITA_CI_INSTALL}
        UPDATE_COMMAND ""
    )

    krita_add_to_ci_targets(ext_python)
endif()
