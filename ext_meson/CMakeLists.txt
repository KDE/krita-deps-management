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
        URL https://github.com/mesonbuild/meson/releases/download/1.1.0/meson-1.1.0.tar.gz
        URL_HASH SHA256=d9616c44cd6c53689ff8f05fc6958a693f2e17c3472a8daf83cee55dabff829f

        CONFIGURE_COMMAND ""

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build -j ${SUBMAKE_JOBS}

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT=<SOURCE_DIR>/setup.py
                        -P ${KRITA_CI_RUN_SETUP_PY_WITH_DESTDIR} -- --skip-build --prefix=${_meson_prefix} --optimize=1  --install-scripts=${_meson_prefix}\\bin --install-lib=${_meson_prefix}\\lib\\site-packages

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )

elseif(NOT CMAKE_CROSSCOMPILING)
    set(_meson_prefix "${EXTPREFIX}")

    ExternalProject_Add( ext_meson
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/mesonbuild/meson/releases/download/1.1.0/meson-1.1.0.tar.gz
        URL_HASH SHA256=d9616c44cd6c53689ff8f05fc6958a693f2e17c3472a8daf83cee55dabff829f

        CONFIGURE_COMMAND chmod u+x <SOURCE_DIR>/setup.py

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            SETUPTOOLS_USE_DISTUTILS=local
            ${Python_EXECUTABLE} <SOURCE_DIR>/setup.py build -j ${SUBMAKE_JOBS}

        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            SETUPTOOLS_USE_DISTUTILS=local
            ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE} -DSCRIPT="<SOURCE_DIR>/setup.py"
                -P ${KRITA_CI_RUN_SETUP_PY_WITH_DESTDIR} -- --skip-build --prefix=${_meson_prefix} --optimize=1 --install-scripts=${_meson_prefix}/bin

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
else()
    set(_meson_prefix "${EXTPREFIX}")
    # Meson needs to be brought manually when crosscompiling.
    ExternalProject_Add(ext_meson
        DOWNLOAD_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Installing meson natively"
                COMMAND ${CMAKE_COMMAND} -E env
                    PYTHONUSERBASE=${_meson_prefix}
                    ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                        -P ${KRITA_CI_RUN_PIP_INSTALL_WITH_DESTDIR} -- --upgrade meson==1.1.0 --user --ignore-installed --verbose

                # logging doesn't work when we are installing meson with DESTDIR
                # COMMAND ${Python_EXECUTABLE} -m pip show -f meson

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_meson)