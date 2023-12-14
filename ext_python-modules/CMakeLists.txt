cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
    cmake_policy(SET CMP0135 NEW)
endif()

project(ext_python-modules)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)
include(${CMAKE_SOURCE_DIR}/../cmake/krita_initialize_python.cmake)

ExternalProject_Add(ext_python-modules
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Creating a lib directory with correct casing (avoid \'Lib\'): ${EXTPREFIX}/lib"
            COMMAND ${CMAKE_COMMAND} -E make_directory -p <BINARY_DIR>/_krita_tmp/lib
            COMMAND ${CMAKE_COMMAND} -DSRC=<BINARY_DIR>/_krita_tmp/ -DDST=${EXTPREFIX} -P ${KRITA_CI_INSTALL_DIRECTORY}
            COMMAND ${CMAKE_COMMAND} -E echo "Installing python-modules natively"
            COMMAND ${CMAKE_COMMAND} -E env
                ${CMAKE_COMMAND} -DPython_EXECUTABLE=${Python_EXECUTABLE}
                    -P ${CMAKE_CURRENT_SOURCE_DIR}/run-pip-install-with-destdir.cmake -- --upgrade -r ${CMAKE_CURRENT_SOURCE_DIR}/../requirements-sip.txt --prefix ${EXTPREFIX} --ignore-installed --verbose
    UPDATE_COMMAND ""
)

krita_add_to_ci_targets(ext_python-modules)

