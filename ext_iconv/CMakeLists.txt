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
		URL https://github.com/win-iconv/win-iconv/archive/v0.0.8.tar.gz
		URL_MD5 e4574721c2d9667af32283175c828833

		CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTPREFIX} -DCMAKE_BUILD_TYPE=${GLOBAL_BUILD_TYPE} ${GLOBAL_PROFILE}

		UPDATE_COMMAND ""
	)

else ()

	ExternalProject_Add( ext_iconv
		DOWNLOAD_DIR ${EXTERNALS_DOWNLOAD_DIR}
		URL https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz
		URL_HASH SHA256=8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313

		CONFIGURE_COMMAND ./configure --prefix=${EXTPREFIX}  ${GLOBAL_AUTOMAKE_PROFILE}

		UPDATE_COMMAND ""
		BUILD_IN_SOURCE 1
	)

endif ()

krita_add_to_ci_targets(ext_iconv)