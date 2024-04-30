if ($ENV{KRITACI_ANDROID_RELEASE_MODE})
    # Activation of the release disables signing the packages
    # with the debug key. The release is going to be signed with
    # a proper key anyway
    message (STATUS "Setting Android Release Mode")
    set(ANDROIDDEPLOYQT_EXTRA_ARGS "--release")
endif()

set(TIFF_HAS_PSD_TAGS TRUE)
set(TIFF_CAN_WRITE_PSD_TAGS TRUE)
set(QTANDROID_EXPORTED_TARGET krita)
set(ANDROID_APK_DIR "${CMAKE_SOURCE_DIR}/packaging/android/apk")

include ("${CMAKE_CURRENT_LIST_DIR}/android-toolchain.cmake" REQUIRED)
