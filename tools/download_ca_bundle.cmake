if (NOT KDECI_CA_BUNDLE_ARG)
    message(FATAL_ERROR "KDECI_CA_BUNDLE_ARG argument is not set!")
endif()

if(DEFINED ENV{CMAKE_TLS_CAINFO} AND EXISTS "$ENV{CMAKE_TLS_CAINFO}")
    message(WARNING "CMAKE_TLS_CAINFO environment is already set... weird, but we will continue")
endif()

if(DEFINED ENV{SSL_CERT_FILE} AND EXISTS "$ENV{SSL_CERT_FILE}")
    message(WARNING "SSL_CERT_FILE environment is already set... weird, but we will continue")
endif()

message(STATUS "Downloading Mozilla CA certificate bundle to ${KDECI_CA_BUNDLE_ARG}...")
file(DOWNLOAD
    "https://curl.se/ca/cacert-2026-10-20.pem"
    "${KDECI_CA_BUNDLE_ARG}"
    TLS_VERIFY ON
    EXPECTED_HASH SHA256=796f1389bfea13c0ed78f663b765baaff54a508e5483786bd6ece73c5e3e3cbe
)
