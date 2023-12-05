function(TestCompileLinkPythonLibs OUTPUT_VARNAME)
	include(CheckCXXSourceCompiles)
	set(CMAKE_REQUIRED_INCLUDES ${Python_INCLUDE_DIRS})
	set(CMAKE_REQUIRED_LIBRARIES ${Python_LIBRARIES})
	if (MINGW)
		set(CMAKE_REQUIRED_DEFINITIONS -D_hypot=hypot)
	endif ()
	unset(${OUTPUT_VARNAME} CACHE)
	CHECK_CXX_SOURCE_COMPILES("
// https://bugs.python.org/issue22411
#if defined(_MSC_VER)
#  ifdef _DEBUG
#    undef _DEBUG
#  endif /* _DEBUG */
#endif /* _MSC_VER */
#include <Python.h>
int main(int argc, char *argv[]) {
	Py_InitializeEx(0);
}" ${OUTPUT_VARNAME})
endfunction()

function(DumpSitePackages PYTHONPATH)
    if (WIN32)
        krita_to_native_path("${${PYTHONPATH}}" _krita_pythonpath)
        string(TOLOWER "${_krita_pythonpath}" _krita_pythonpath)
    else()
        set(_krita_pythonpath ${${PYTHONPATH}})
    endif()
    execute_process(COMMAND ${CMAKE_COMMAND}
        -E env PYTHONPATH=${_krita_pythonpath}
        ${Python_EXECUTABLE} -c "import sysconfig; print(sysconfig.get_paths());"
        OUTPUT_VARIABLE __sysconfig)
    message(STATUS "Python's system directories: ${__sysconfig}")
    execute_process(COMMAND ${CMAKE_COMMAND}
        -E env PYTHONPATH=${_krita_pythonpath}
        ${Python_EXECUTABLE} -c "from setuptools.command import easy_install; print(easy_install.get_site_dirs())"
        OUTPUT_VARIABLE __setuptools)
    message(STATUS "Python's setuptools directories: ${__setuptools}")
endfunction()

if (WIN32)
    option(ENABLE_PYTHON_DEPS "Enable Python deps (sip, pyqt)" ON)
    if (ENABLE_PYTHON_DEPS)
        set(KRITA_PYTHONPATH "${EXTPREFIX}/lib/site-packages;$ENV{PYTHONPATH}")
        message(STATUS "Krita's PEP-0250 root: ${KRITA_PYTHONPATH}")
        set(Python_FIND_STRATEGY LOCATION)
        find_package(Python 3.8 COMPONENTS Development Interpreter)
        if (Python_FOUND)
            message(STATUS "Python requirements met.")
            TestCompileLinkPythonLibs(CAN_USE_PYTHON_LIBS)
            DumpSitePackages(KRITA_PYTHONPATH)
            if (NOT CAN_USE_PYTHON_LIBS)
                file(READ ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log ERROR_LOG)
                string(REPLACE "\n" "\n  " ERROR_LOG "${ERROR_LOG}")
                message(FATAL_ERROR "Compiling with Python library failed, please check whether the architecture is correct!\nCMakeError.log:\n  ${ERROR_LOG}\n\n")
            endif ()
        else ()
            message(FATAL_ERROR "Python requirements not met. To disable Python deps, set ENABLE_PYTHON_DEPS to OFF.")
        endif ()
    endif ()
elseif(UNIX)
    set(PYTHON_VERSION "3.10")

    set(KRITA_PYTHONPATH "${EXTPREFIX}/lib/python${PYTHON_VERSION}/site-packages")
    set(Python_EXECUTABLE "${EXTPREFIX}/bin/python3")
    if(NOT EXISTS "${Python_EXECUTABLE}")
        message("WARNING: using system python3!")
        SET(Python_EXECUTABLE python3)
    endif()
    message(STATUS "Krita's PEP-0250 root: ${KRITA_PYTHONPATH}")
endif ()

# Prepare meson-compatible environment variables
if (WIN32)
    krita_to_native_path("${KRITA_PYTHONPATH}" _krita_pythonpath)
    string(TOLOWER ${_krita_pythonpath} _krita_pythonpath)
    krita_to_native_environment_path_list("${_krita_pythonpath}" _krita_pythonpath)
else()
    set(_krita_pythonpath ${KRITA_PYTHONPATH})
endif()

message(STATUS "Python environment for Krita: ${_krita_pythonpath}")
message(STATUS "Python executable: ${Python_EXECUTABLE}")