ui = true
disable_mlock = true
log_level = "INFO"
api_addr = "https://0.0.0.0:8200"

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/cert/fullchain.pem"
  tls_key_file = "/cert/privkey.pem"
  tls_client_ca_file = "/cert/client_ca.pem"
  tls_require_and_verify_client_cert = "true"
}

storage "file" {
  path = "/data/vault/data"
}
