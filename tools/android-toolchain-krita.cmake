if ($ENV{KRITACI_RELEASE})
    set(ANDROIDDEPLOYQT_EXTRA_ARGS "--release")
else()
    set(ANDROIDDEPLOYQT_EXTRA_ARGS "--no-gdbserver")
endif()

set(TIFF_HAS_PSD_TAGS TRUE)
set(TIFF_CAN_WRITE_PSD_TAGS TRUE)
set(QTANDROID_EXPORTED_TARGET krita)
set(ANDROID_APK_DIR "${CMAKE_SOURCE_DIR}/packaging/android/apk")

include ("${CMAKE_CURRENT_LIST_DIR}/android-toolchain.cmake" REQUIRED)
