cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_qt)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

set(QT_GIT_TAG "4eabbfbbcfc6bb0ab1045672d18c836cb7040e41")

if (MINGW)
  set(QT_BUILD_COMMAND   mingw32-make -j${SUBMAKE_JOBS})
  set(QT_INSTALL_COMMAND ${CMAKE_COMMAND} -DMAKE_COMMAND=mingw32-make -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- -j${SUBMAKE_JOBS} install)
elseif (MSVC)
  set(QT_BUILD_COMMAND jom -j${SUBMAKE_JOBS})
  set(QT_INSTALL_COMMAND ${CMAKE_COMMAND} -DMAKE_COMMAND=jom -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- -j${SUBMAKE_JOBS} install)
  set(QT_INSTALL_COMMAND jom -j${SUBMAKE_JOBS} install)
elseif (CMAKE_GENERATOR MATCHES "Makefiles")
  set (QT_BUILD_COMMAND $(MAKE) -j${SUBMAKE_JOBS})
  set(QT_INSTALL_COMMAND ${CMAKE_COMMAND} -DMAKE_COMMAND=$(MAKE) -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- -j${SUBMAKE_JOBS} install)
else()
  set (QT_BUILD_COMMAND make -j${SUBMAKE_JOBS})
  set(QT_INSTALL_COMMAND ${CMAKE_COMMAND} -DMAKE_COMMAND=make -P ${KRITA_CI_RUN_MAKE_WITH_INSTALL_ROOT} -- install)
endif()

if (WIN32)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      set(QT_CONFIG_PLATFORM win32-clang-g++)
    else()
      set(QT_CONFIG_PLATFORM win32-g++)
    endif()

    set(QT_BUILD_TYPE Release)
    set(EXTRA_CMAKE_OPTIONS)
    set(EXTRA_C_FLAGS_ALL)
    set(EXTRA_CXX_FLAGS_ALL)
    set(EXTRA_C_FLAGS_RELEASE)
    set(EXTRA_CXX_FLAGS_RELEASE)

    if(QT_ENABLE_DEBUG_INFO)
      set(QT_BUILD_TYPE RelWithDebInfo)
    endif()

    if (QT_ENABLE_ASAN)
      set(QT_BUILD_TYPE RelWithDebInfo)
      list(APPEND EXTRA_CMAKE_OPTIONS -DFEATURE_sanitize_address=ON)
    endif ()

    # Generate minimal debug info for backtraces in release mode
    list(APPEND EXTRA_C_FLAGS_RELEASE -g1)
    list(APPEND EXTRA_CXX_FLAGS_RELEASE -g1)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      # This is needed for proper C++ function signatures in Release mode
      list(APPEND EXTRA_C_FLAGS_RELEASE -fdebug-info-for-profiling)
      list(APPEND EXTRA_CXX_FLAGS_RELEASE -fdebug-info-for-profiling)

      # Workaround for DrMingw, see parent CMakeLists.txt
      list(APPEND EXTRA_C_FLAGS_ALL -gdwarf-aranges)
      list(APPEND EXTRA_CXX_FLAGS_ALL -gdwarf-aranges)
    endif ()

    list(APPEND _QT_conf
         -nomake examples -nomake tools -nomake benchmarks -nomake manual-tests -nomake minimal-static-tests
        -no-dbus -no-qml-debug -no-libproxy -no-system-proxies -icu -no-mtdev
        -qt-sqlite
        -no-feature-assistant -no-feature-designer -feature-linguist -no-feature-androiddeployqt
        #
        -system-zlib -qt-pcre -system-libpng -system-libjpeg -openssl-linked -system-freetype -system-harfbuzz
        -I ${EXTPREFIX}/include
        -L ${EXTPREFIX}/lib
        #
        -opensource -confirm-license
        -feature-relocatable
        -no-feature-qdoc
        #
        -platform ${QT_CONFIG_PLATFORM} -prefix ${EXTPREFIX}
        --
        # we ship our own version of freedesktop.org.xml database
        # which has Krita-specific formats and translations, so we
        # can disable the internal database shipped with Qt
        -DFEATURE_mimetype_database=OFF
        # -DFEATURE_direct2d=OFF
        # -DFEATURE_directwrite=OFF
        # -DFEATURE_directwrite3=OFF
        -DFEATURE_opengl=ON # ensure openGL is activated
        -DFEATURE_egl=ON # enable ANGLE backend
        #
        -DCMAKE_BUILD_TYPE=${QT_BUILD_TYPE}
        -DCMAKE_C_FLAGS_INIT="${EXTRA_C_FLAGS_ALL}"
        -DCMAKE_CXX_FLAGS_INIT="${EXTRA_CXX_FLAGS_ALL}"
        -DCMAKE_C_FLAGS_RELEASE_INIT="${EXTRA_C_FLAGS_RELEASE}"
        -DCMAKE_CXX_FLAGS_RELEASE_INIT="${EXTRA_CXX_FLAGS_RELEASE}"
        ${GLOBAL_PROFILE}
        ${EXTRA_CMAKE_OPTIONS}
    )

  ExternalProject_Add(
      ext_qt
      DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
      GIT_REPOSITORY https://github.com/dimula73/qt5.git
      GIT_TAG ${QT_GIT_TAG}
      # TODO: still need to be recovered: qtwinextras
      GIT_SUBMODULES qtbase qtdeclarative qtimageformats qttools qtsvg qttranslations qt5compat qtshadertools
      GIT_SUBMODULES_RECURSE false
      GIT_PROGRESS true
      GIT_REMOTE_UPDATE_STRATEGY REBASE

      # unset QMAKEFEATURES to allow incremental builds with run-ci-build.py
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env --unset=QMAKEFEATURES
          <SOURCE_DIR>/configure.bat ${_QT_conf}

      BUILD_COMMAND ${CMAKE_COMMAND} --build . --target all --parallel ${SUBMAKE_JOBS}
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

      UPDATE_COMMAND ""

      # Use a short name to reduce the chance of exceeding path length limit
      SOURCE_DIR s
      BINARY_DIR b
  )

  ExternalProject_Add_StepTargets(ext_qt configure)

elseif (ANDROID)
  include(${CMAKE_SOURCE_DIR}/FilterEnvironmentPathList.cmake)

  # We strip all the cross-compiled PATH, LD_LIBRARY_PATH and PKG_CONFIG_PATH
  # locations from the environment to make sure the host-tools are build correctly.
  # 
  # CMAKE_PREFIX_PATH and CMAKE_TOOLCHAIN_FILE should just be unset for the host 
  # tools.
  filter_environment_path_list(PATH "${EXTPREFIX}" HOST_ONLY_PATH)
  filter_environment_path_list(LD_LIBRARY_PATH "${EXTPREFIX}" HOST_ONLY_LD_LIBRARY_PATH)
  filter_environment_path_list(PKG_CONFIG_PATH "${EXTPREFIX}" HOST_ONLY_PKG_CONFIG_PATH)

  message(STATUS "Host PATH: ${HOST_ONLY_PATH}")
  message(STATUS "Host LD_LIBRARY_PATH: ${HOST_ONLY_LD_LIBRARY_PATH}")
  message(STATUS "Host PKG_CONFIG_PATH: ${HOST_ONLY_PKG_CONFIG_PATH}")

  set(PAGE_ALIGNMENT_PATCH_ARG)
  if (PAGE_ALIGN_16K_LINKER_FLAGS)
    message(STATUS "Enable 16K page alignment for Qt5")
    # TODO: disable 16K alignement patch for now
    # set(PAGE_ALIGNMENT_PATCH_ARG
    #     COMMAND ${PATCH_COMMAND} -d qtbase -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-Force-enable-16K-alignment-on-Android.patch)
  endif()

  ExternalProject_Add(
      ext_qt
      DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

      GIT_REPOSITORY https://github.com/dimula73/qt5.git
      GIT_TAG ${QT_GIT_TAG}
      # TODO: still need to be recovered: qtgraphicaleffects qtandroidextras
      GIT_SUBMODULES qtbase qtdeclarative qtimageformats qttools qtsvg qttranslations qt5compat qtshadertools
      GIT_SUBMODULES_RECURSE false
      GIT_PROGRESS true
      GIT_REMOTE_UPDATE_STRATEGY REBASE

      # unset QMAKEFEATURES to allow incremental builds with run-ci-build.py
      # TODO(sh_zam): We can probably skip the skipping now.
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env --unset=QMAKEFEATURES
          <SOURCE_DIR>/configure -prefix ${EXTPREFIX} -opensource -confirm-license -verbose
          -android-sdk ${ANDROID_SDK_ROOT} -android-ndk ${CMAKE_ANDROID_NDK} -android-abis ${ANDROID_ABI}
          -xplatform android-clang -android-ndk-platform android-24
          -make libs -qt-sqlite -openssl-linked OPENSSL_PREFIX=${EXTPREFIX} -system-zlib
          -nomake examples -nomake tests -nomake tools -skip qt3d -skip qtactiveqt -skip qtcanvas3d
          -skip qtconnectivity -skip qtlocation -skip qtwayland -skip qtwebchannel -skip qtwebengine
          -skip qtwebsockets -skip qtwebview -skip qtserialport  -skip qtvirtualkeyboard -skip qtspeech
          -skip qtsensors  -skip qtscxml -skip qtremoteobjects -skip qtxmlpatterns -skip qtnetworkauth
          -skip qtcharts -skip qtdatavis3d -skip qtgamepad -skip qtpurchasing  -skip qtserialbus
          -icu
          -I ${EXTPREFIX}/include
          -L ${EXTPREFIX}/lib
          -no-feature-assistant -no-feature-designer
          -qt-host-path <TMP_DIR>/hosttools/qtbase
          --
          -Wno-dev
          # we ship our own version of freedesktop.org.xml database
          # which has Krita-specific formats and translations, so we
          # can disable the internal database shipped with Qt
          -DFEATURE_mimetype_database=OFF

#      PATCH_COMMAND ${PATCH_COMMAND} -d qtbase -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-android-Fix-build-with-NDK-27.patch
#             COMMAND ${PATCH_COMMAND} -d qtbase -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-android-Fix-ranlib-path-for-NDK-27.patch
#             COMMAND ${PATCH_COMMAND} -d qtbase -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0001-androiddeloyqt-fix-needed-libs-argument-for-llvm-rea.patch

      BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${SUBMAKE_JOBS}
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --parallel ${SUBMAKE_JOBS} --target install

      UPDATE_COMMAND ""
  )

  ExternalProject_Add_Step(ext_qt hosttools-dirs
    COMMENT "Making directories for host-tools"
    COMMAND ${CMAKE_COMMAND} 
      -E make_directory <TMP_DIR>/hosttools
  )

  ExternalProject_Add_Step(ext_qt hosttools-configure
    COMMENT "Configuring host-tools (moc, qsb...)"
    COMMAND ${CMAKE_COMMAND} 
      -E env 
        --unset=QMAKEFEATURES
        # disable cross-compilation variables for host tools
        --unset=CMAKE_PREFIX_PATH
        --unset=CMAKE_TOOLCHAIN_FILE
        PKG_CONFIG_PATH=${HOST_ONLY_PKG_CONFIG_PATH}
        LD_LIBRARY_PATH=${HOST_ONLY_LD_LIBRARY_PATH}
        PATH=${HOST_ONLY_PATH}
        <SOURCE_DIR>/configure -release -developer-build
          -nomake tests -nomake examples
          -no-widgets -no-dbus
          -skip qt5compat -skip qtimageformats -skip qtsvg -skip qttranslations
          -no-feature-sql
          -no-feature-network
          -no-feature-testlib 
          -- -Wno-dev

    DEPENDEES hosttools-dirs patch
    WORKING_DIRECTORY <TMP_DIR>/hosttools
  )

  ExternalProject_Add_Step(ext_qt hosttools
    COMMENT "Building host-tools (moc, qsb...)"
    COMMAND ${CMAKE_COMMAND} 
      -E env 
        --unset=QMAKEFEATURES
        # disable cross-compilation variables for host tools
        --unset=CMAKE_PREFIX_PATH
        --unset=CMAKE_TOOLCHAIN_FILE
        PKG_CONFIG_PATH=${HOST_ONLY_PKG_CONFIG_PATH}
        LD_LIBRARY_PATH=${HOST_ONLY_LD_LIBRARY_PATH}
        PATH=${HOST_ONLY_PATH}
        ${CMAKE_COMMAND} --build . --target host_tools --parallel ${SUBMAKE_JOBS}

    DEPENDEES hosttools-configure
    WORKING_DIRECTORY <TMP_DIR>/hosttools

    DEPENDERS configure
  )

  ExternalProject_Add_StepTargets(ext_qt hosttools)
  ExternalProject_Add_StepTargets(ext_qt configure)

elseif (NOT APPLE)
    if (QT_ENABLE_DEBUG_INFO)
        # Set the option to build Qt with debugging info enabled
        set(QT_DEBUG_OPTIONS -force-debug-info)
    endif()
    if (QT_ENABLE_ASAN)
        list(APPEND QT_DEBUG_OPTIONS -sanitize address)
    endif ()


    ExternalProject_Add(
      ext_qt
      DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

      # replace to avoid refetch on rebuilds
      #SOURCE_DIR ext_qt-prefix/src/ext_qt

      GIT_REPOSITORY https://github.com/dimula73/qt5.git
      GIT_TAG ${QT_GIT_TAG}
      # TODO: still need to be recovered: qtgraphicaleffects
      GIT_SUBMODULES qtbase qtdeclarative qtimageformats qttools qtsvg qttranslations qt5compat qtwayland qtshadertools
      GIT_SUBMODULES_RECURSE false
      GIT_PROGRESS true
      GIT_REMOTE_UPDATE_STRATEGY REBASE

      # TODO: check if QMAKEFEATURES setting is still needed

      # unset QMAKEFEATURES to allow incremental builds with run-ci-build.py
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env --unset=QMAKEFEATURES
          <SOURCE_DIR>/configure -prefix ${EXTPREFIX}
                  -opensource -confirm-license
                  -feature-relocatable -openssl-linked -verbose -nomake examples
                  -qt-sqlite

                    -no-feature-assistant -no-feature-designer -feature-linguist
                  -no-feature-androiddeployqt -no-eglfs -no-linuxfb -no-feature-vnc -feature-xcb

                  -system-zlib -system-libpng -system-libjpeg -system-freetype -system-harfbuzz
          ${QT_DEBUG_OPTIONS}
          --
          # we ship our own version of freedesktop.org.xml database
          # which has Krita-specific formats and translations, so we
          # can disable the internal database shipped with Qt
          -DFEATURE_mimetype_database=OFF
          # we don't plan to build our own wayland server
          -DFEATURE_wayland_server=OFF

      BUILD_COMMAND ${CMAKE_COMMAND} --build . --target all --parallel ${SUBMAKE_JOBS}
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

      UPDATE_COMMAND ""
      BUILD_IN_SOURCE OFF
  )
else( APPLE )

    set(MACOS_QT_CONFIGURE_OPS
        -skip qt3d -skip qtactiveqt -skip qtcanvas3d -skip qtconnectivity -skip qtdoc -skip qtlocation -skip qtsensors -skip qtserialport -skip qtwayland
        -skip qtwebchannel -skip qtwebsockets -skip qtwebview -skip qtwebengine -skip qtxmlpatterns
        -skip qtcharts -skip qtdatavis3d  -skip qtgamepad -skip qtnetworkauth
        -skip qtpurchasing -skip qtremoteobjects -skip qtscxml -skip qtserialbus -skip qtspeech -skip qtvirtualkeyboard -nomake examples -nomake tools
        -no-dbus -no-qml-debug -no-libproxy -no-system-proxies -icu -no-mtdev
        -system-zlib -qt-pcre -qt-sqlite
        -no-feature-assistant -no-feature-designer -feature-linguist
        -system-libpng -system-libjpeg -system-freetype -system-harfbuzz
        -opensource -confirm-license -openssl-linked -prefix ${EXTPREFIX}
        OPENSSL_PREFIX=${EXTPREFIX}
        -I ${EXTPREFIX}/include
        -L ${EXTPREFIX}/lib
        --
        # todo: don't hardcode the archs
        -DCMAKE_OSX_ARCHITECTURES="x86_64$<SEMICOLON>arm64"
        # we ship our own version of freedesktop.org.xml database
        # which has Krita-specific formats and translations, so we
        # can disable the internal database shipped with Qt
        -DFEATURE_mimetype_database=OFF
    )

    ExternalProject_Add(
      ext_qt

      GIT_REPOSITORY https://github.com/dimula73/qt5.git
      GIT_TAG ${QT_GIT_TAG}
      # TODO: still need to be recovered: qtgraphicaleffects qtmacextras
      GIT_SUBMODULES qtbase qtdeclarative qtimageformats qttools qtsvg qttranslations qt5compat qtshadertools
      GIT_SUBMODULES_RECURSE false
      GIT_PROGRESS true
      GIT_REMOTE_UPDATE_STRATEGY REBASE

      # unset QMAKEFEATURES to allow incremental builds with run-ci-build.py
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "OPENSSL_LIBS=-L${EXTPREFIX}/lib -lssl -lcrypto" --unset=QMAKEFEATURES
          <SOURCE_DIR>/configure
          ${MACOS_QT_CONFIGURE_OPS}

      BUILD_COMMAND ${CMAKE_COMMAND} --build . --parallel ${SUBMAKE_JOBS}
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
    )

endif()

krita_add_to_ci_targets(ext_qt)