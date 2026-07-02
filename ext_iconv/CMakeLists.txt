cmake_minimum_required(VERSION 3.21)
if(POLICY CMP0135) # remove if after cmake 3.23 is the minimum
	cmake_policy(SET CMP0135 NEW)
endif()

project(ext_iconv)
include(${CMAKE_SOURCE_DIR}/../cmake/base-dep-options.cmake)

# NOTE: iconv support is present on Linux as part of GNU libc implementation,
# so we don't need to build and install it separtely on Linux.

if (WIN32)

	ExternalProject_Add( ext_iconv
		DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
		DOWNLOAD_NAME win-iconv-v0.0.8.tar.gz
		URL https://github.com/win-iconv/win-iconv/archive/v0.0.10.tar.gz
		URL_MD5 fa45ad25b003942ca768cfcdf59dc5be

		CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

		UPDATE_COMMAND ""
	)

else ()

	ExternalProject_Add( ext_iconv
		DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
		URL https://ftp.gnu.org/gnu/libiconv/libiconv-1.19.tar.gz
		URL_HASH SHA256=88dd96a8c0464eca144fc791ae60cd31cd8ee78321e67397e25fc095c4a19aa6

		CONFIGURE_COMMAND ./configure --prefix=${EXTPREFIX}  ${GLOBAL_AUTOMAKE_PROFILE}

		UPDATE_COMMAND ""
		BUILD_IN_SOURCE 1
	)

endif ()

krita_add_to_ci_targets(ext_iconv)
