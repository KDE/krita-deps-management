cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_drmingw)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

if (MINGW)
    # to work around DESTDIR logic, we only download the file for ext_drmingw_deps here, and install it with a pre_install step in the main project (ext_drmingw)
    set(DRMINGW_DEPS_BINARIES ${CMAKE_CURRENT_BINARY_DIR}/drmingw_extracted_binaries)

    ExternalProject_Add(ext_drmingw_deps
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/jrfonseca/drmingw/releases/download/0.9.7/drmingw-0.9.7-win64.7z
        URL_HASH SHA256=ff1a62ebc9e0662c7ba7f30141efa047e6ee43a5f1a613f671b0971ba772d597

        SOURCE_DIR ${DRMINGW_DEPS_BINARIES}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""

        UPDATE_COMMAND ""
    )

    ExternalProject_Add(ext_drmingw
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/amyspark/drmingw/releases/download/0.9.7.1/drmingw-0.9.7.1-patched.tar.gz
        URL_HASH SHA256=998848da2f490bfea455f804ccc3f08bc5d5d0fee7813b406c658451ce6da532

        INSTALL_DIR ${EXTPREFIX}
        CMAKE_ARGS -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=1 -DCMAKE_DISABLE_FIND_PACKAGE_WinDbg=1 -DPOSIX_THREADS=1 -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

        UPDATE_COMMAND ""
        
        DEPENDS ext_drmingw_deps
    )
    
    ExternalProject_Add_Step(ext_drmingw
        pre_install
        
        COMMAND ${CMAKE_COMMAND} -DSRC=${DRMINGW_DEPS_BINARIES}/bin/dbghelp.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
        COMMAND ${CMAKE_COMMAND} -DSRC=${DRMINGW_DEPS_BINARIES}/bin/dbgcore.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
        COMMAND ${CMAKE_COMMAND} -DSRC=${DRMINGW_DEPS_BINARIES}/bin/symsrv.dll  -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
        COMMAND ${CMAKE_COMMAND} -DSRC=${DRMINGW_DEPS_BINARIES}/bin/symsrv.yes  -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
        
        DEPENDERS install
    )
elseif(MSVC)
    ExternalProject_Add(ext_drmingw
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
        URL https://github.com/jrfonseca/drmingw/releases/download/0.9.7/drmingw-0.9.7-win64.7z
        URL_HASH SHA256=ff1a62ebc9e0662c7ba7f30141efa047e6ee43a5f1a613f671b0971ba772d597

        INSTALL_DIR ${EXTPREFIX}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo Deploying Dr. MinGW 64-bit dependencies (MSVC)
        INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/dbghelp.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/dbgcore.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/symsrv.dll  -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/symsrv.yes  -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/exchndl.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}
                COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin/mgwhelp.dll -DDST=${EXTPREFIX}/bin -P ${KRITA_CI_INSTALL}

        UPDATE_COMMAND ""
    )
endif (MINGW)

krita_add_to_ci_targets(ext_drmingw)
