if (NOT KDECI_CA_BUNDLE)
    message(FATAL_ERROR "KDECI_CA_BUNDLE argument is not set!")
endif()

if(DEFINED ENV{CMAKE_TLS_CAINFO} AND EXISTS "$ENV{CMAKE_TLS_CAINFO}")
    message(WARNING "CMAKE_TLS_CAINFO environment is already set... weird, but we will continue")
endif()

if(DEFINED ENV{SSL_CERT_FILE} AND EXISTS "$ENV{SSL_CERT_FILE}")
    message(WARNING "SSL_CERT_FILE environment is already set... weird, but we will continue")
endif()

message(STATUS "Downloading Mozilla CA certificate bundle to ${KDECI_CA_BUNDLE}...")
file(DOWNLOAD
    "https://curl.se/ca/cacert-2026-03-19.pem"
    "${KDECI_CA_BUNDLE}"
    TLS_VERIFY ON
    EXPECTED_HASH SHA256=b6e66569cc3d438dd5abe514d0df50005d570bfc96c14dca8f768d020cb96171
)