if (DEFINED ENV{KDECI_ANDROID_ABI})
    set(ANDROID_ABI $ENV{KDECI_ANDROID_ABI})
endif()

if (NOT ANDROID_ABI)
    message(FATAL_ERROR "ANDROID_ABI option is not set! (options are: x86_64 armeabi-v7a arm64-v8a)")
endif()

if (NOT DEFINED ENV{KDECI_ANDROID_SDK_ROOT})
    message(FATAL_ERROR "KDECI_ANDROID_SDK_ROOT environment variable is not set!")
endif()

if (NOT DEFINED ENV{KDECI_ANDROID_NDK_ROOT})
    message(FATAL_ERROR "KDECI_ANDROID_NDK_ROOT environment variable is not set!")
endif()

set(KRITA_ANDROID_NATIVE_API_LEVEL 23)
set(KRITA_ANDROID_SDK_API_LEVEL 33)

if (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    # Meson injects -D_FILE_OFFSET_BITS=64 which triggers off_t functions.
    # Alternatively, increase API level to 24.
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_LIBCPP_HAS_NO_OFF_T_FUNCTIONS")
endif()

set(ANDROID_PLATFORM "android-${KRITA_ANDROID_NATIVE_API_LEVEL}")
set(ANDROID_SDK_COMPILE_API "android-${KRITA_ANDROID_SDK_API_LEVEL}")
set(ANDROID_SDK_ROOT "$ENV{KDECI_ANDROID_SDK_ROOT}")
set(CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}" "${CMAKE_FIND_ROOT_PATH}")
set(ANDROID_STL c++_shared)

include ("$ENV{KDECI_ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" REQUIRED)
