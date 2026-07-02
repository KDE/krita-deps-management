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
        URL https://github.com/jrfonseca/drmingw/releases/download/0.9.13/drmingw-0.9.13-win64.7z
        URL_HASH SHA256=a2404a2ae3e03386b579bdd98d2d38f1f6aecbf7167d907eeaff44f35097a0e0

        SOURCE_DIR ${DRMINGW_DEPS_BINARIES}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""

        UPDATE_COMMAND ""
    )

    ExternalProject_Add(ext_drmingw
        DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}

        GIT_REPOSITORY https://github.com/jrfonseca/drmingw.git
        GIT_TAG 0.9.13
        GIT_SUBMODULES_RECURSE FALSE
        GIT_PROGRESS TRUE

        INSTALL_DIR ${EXTPREFIX}
        CMAKE_ARGS -DCMAKE_DISABLE_FIND_PACKAGE_WinDbg=1 -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

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
endif()

krita_add_to_ci_targets(ext_drmingw)
