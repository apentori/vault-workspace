ui = true
disable_mlock = true
log_level = "INFO"
api_addr = "http://178.27.1.7:8200"
cluster_addr = "http://178.27.1.7:8201"

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
  telemetry {
      unauthenticated_metrics_access = true
  }
}

telemetry {
  prometheus_retention_time = "10m"
  disable_hostname = true
}

storage "raft" {
  path = "/tmp"
  node_id = "node-03"
  retry_join {
    leader_api_addr = "http://178.27.1.5:8200"
  }
  retry_join {
    leader_api_addr = "http://178.27.1.6:8200"
  }
}
