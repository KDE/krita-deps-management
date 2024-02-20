cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_pyqt5)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

if(UNIX)
    if (QT_ENABLE_ASAN)
       set(_extra_pyqt_config --qmake-setting QMAKE_LFLAGS+=-fsanitize=address --qmake-setting QMAKE_CFLAGS+=-fsanitize=address --qmake-setting QMAKE_CXXFLAGS+=-fsanitize=address)
    elseif(APPLE)
        if(MACOS_ARCHS GREATER 1)
            set(_extra_pyqt_config --qmake-setting "QMAKE_APPLE_DEVICE_ARCHS=${CMAKE_OSX_ARCHITECTURES_STR}")
        endif()
    else ()
       unset(_extra_pyqt_config)
    endif ()

    ExternalProject_Add( ext_pyqt5
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/P/PyQt5/PyQt5-5.15.7.tar.gz
        URL_HASH SHA256=755121a52b3a08cb07275c10ebb96576d36e320e572591db16cfdbc558101594

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-Qt-composite-module-lacking-a-platform-tag-on-ma.patch
              COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-restrict-sip-version.patch

        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${EXTPREFIX}/bin/sip-build --confirm-license --no-designer-plugin --no-qml-plugin --no-dbus-python --no-tools --no-make --jobs ${SUBMAKE_JOBS} ${_extra_pyqt_config}

        BUILD_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/build
            make -j${SUBMAKE_JOBS}

        # force single-threaded installation to avoid
        # race conditions in post-install .py script
        INSTALL_COMMAND ${CMAKE_COMMAND} -E env 
            "PYTHONPATH=${KRITA_PYTHONPATH}"
            ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/build
            ${CMAKE_COMMAND} -DMAKE_COMMAND=make -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- -j1 install
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

    if (QT_ENABLE_ASAN)
       set(_extra_pyqt_config --qmake-setting QMAKE_LFLAGS+=-fsanitize=address --qmake-setting QMAKE_CFLAGS+=-fsanitize=address --qmake-setting QMAKE_CXXFLAGS+=-fsanitize=address)
    else ()
       unset(_extra_pyqt_config)
    endif ()

    krita_to_native_path("${EXTPREFIX}" _pyqt_prefix)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)

    ExternalProject_Add( ext_pyqt5
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://pypi.python.org/packages/source/P/PyQt5/PyQt5-5.15.7.tar.gz
        URL_HASH SHA256=755121a52b3a08cb07275c10ebb96576d36e320e572591db16cfdbc558101594

        PATCH_COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Fix-Qt-composite-module-lacking-a-platform-tag-on-ma.patch
              COMMAND ${PATCH_COMMAND} -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-restrict-sip-version.patch

        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${EXTPREFIX}/bin/sip-build --confirm-license --no-designer-plugin --no-qml-plugin --no-dbus-python --no-tools --no-make --target-dir ${EXTPREFIX}\\lib\\site-packages --jobs ${SUBMAKE_JOBS} ${_extra_pyqt_config}

        BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/build
            ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${_make_command} -j${SUBMAKE_JOBS}

        # force single-threaded installation to avoid
        # race conditions in post-install .py script
        INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/build
            ${CMAKE_COMMAND} -E env 
            PYTHONPATH=${_krita_pythonpath}
            ${CMAKE_COMMAND} -DMAKE_COMMAND=${_make_command} -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- -j1 install

        BUILD_IN_SOURCE 1

        UPDATE_COMMAND ""
    )
endif()

krita_add_to_ci_targets(ext_pyqt5)