set(X265_SHARED_PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A01-Do-not-set-thread-priority-on-Windows.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A02-Apple-Silicon-tuning.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A03-Implement-ambient-viewing-environment-sei.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A04-add-new-matrix-coefficients-from-H.273-v3.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A05-Fix-Dolby-Vision-RPU-memory-management.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A06-Update-version-strings.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A07-Fix-macOS-cross-compilation.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A08-Fix-inconsistent-bitrate-in-second-pass.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/handbrake/A09-Ensuring-the-mvdLX-is-compliant.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/0001-ext_heif-Make-sure-that-pthreads-are-not-linked-it-o.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/0002-Skip-PDB-in-MinGW.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/0003-Fix-a-crash-when-trying-to-export-a-lossless-image.patch
)

set(X265_SHARED_PATCH_COMMAND)

foreach (PATCH_FILE ${X265_SHARED_PATCHES})
    if (NOT EXISTS ${PATCH_FILE})
        message(FATAL_ERROR "Patch file doesn't exist: ${PATCH_FILE}")
    endif()

    if (NOT X265_SHARED_PATCH_COMMAND)
        list(APPEND X265_SHARED_PATCH_COMMAND PATCH_COMMAND ${PATCH_COMMAND} -p1 -i)
    else()
        list(APPEND X265_SHARED_PATCH_COMMAND COMMAND ${PATCH_COMMAND} -p1 -i)
    endif()

    list(APPEND X265_SHARED_PATCH_COMMAND ${PATCH_FILE})
endforeach()
