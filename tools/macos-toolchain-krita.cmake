if ($ENV{KRITACI_RELEASE})
    # todo
else()
    # todo
endif()

set(KDE_INSTALL_BUNDLEDIR "${CMAKE_INSTALL_PREFIX}/bin")
set(PYQT_SIP_DIR_OVERRIDE "${CMAKE_INSTALL_PREFIX}/share/sip/")
set(PYTHON_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/lib/Python.framework/Headers")
set(MACOS_UNIVERSAL TRUE)

include ("${CMAKE_CURRENT_LIST_DIR}/macos-toolchain.cmake" REQUIRED)

