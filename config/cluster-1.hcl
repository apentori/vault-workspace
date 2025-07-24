ui = true
disable_mlock = true
log_level = "INFO"
api_addr = "https://178.27.1.5:8200"
cluster_addr = "https://178.27.1.5:8201"

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/cert/fullchain.pem"
  tls_key_file = "/cert/privkey.pem"
  tls_client_ca_file = "/cert/client_ca.pem"
  tls_require_and_verify_client_cert = "true"
}

storage "raft" {
  path = "/tmp"
  node_id = "node-01"
  retry_join {
    leader_api_addr = "https://178.27.1.5:8200"
    leader_ca_cert_file = "/cert/client_ca.pem"
    leader_client_key_file = "/cert/client_cluster.key"
    leader_client_cert_file = "/cert/client_cluster.crt"
  }
  retry_join {
    leader_api_addr = "https://178.27.1.6:8200"
    leader_ca_cert_file = "/cert/client_ca.pem"
    leader_client_key_file = "/cert/client_cluster.key"
    leader_client_cert_file = "/cert/client_cluster.crt"
  }
  retry_join {
    leader_api_addr = "https://178.27.1.7:8200"
    leader_ca_cert_file = "/cert/client_ca.pem"
    leader_client_key_file = "/cert/client_cluster.key"
    leader_client_cert_file = "/cert/client_cluster.crt"
  }
}
