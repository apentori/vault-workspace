#!/usr/bin/env bash
export VAULT_FORMAT=json

load_token() {
  KEYS_FILE="vault-keys.json"
  export VAULT_TOKEN="$(jq -r '.root_token' "${KEYS_FILE}")"
}

cluster_status() {
  PORT=8200
  if [ $# -eq 1 ]
    then
      PORT=$1
  fi
  VAULT_ADDR="http://localhost:$PORT"
  KEYS_FILE="vault-keys.json"
  export VAULT_ADDR
  export VAULT_TOKEN="$(jq -r '.root_token' "${KEYS_FILE}")"
  echo "Cluster Status:"
  vault operator raft autopilot state --format=json | jq -r '.Servers | to_entries[] | [.key, .value.Status, .value.NodeStatus, .value.Version, .value.Healthy] | @tsv' \
    | column -t -N NAME,STATUS,NODESTATUS,VERSION,HEALTHY
}


unsealing_nodes() {
    PORT=8200
  if [ $# -eq 1 ]
    then
      PORT=$1
  fi
  VAULT_ADDR="http://localhost:$PORT"
  KEYS_FILE="vault-keys.json"
  UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' "${KEYS_FILE}")
  vault status | jq -r '"Vault Status : Initialized \(.initialized), sealed: \(.sealed)"'
  echo ""
  echo "=> Unsealing Vault"
  echo ""
  vault operator unseal "${UNSEAL_KEY}" > /dev/null
  sleep 5
  vault status | jq -r '"Vault Status : Initialized \(.initialized), sealed: \(.sealed)"'
  echo ""
  echo "==> Listing secrets engine"
  echo""
  vault secrets list | jq 'keys'
}

get_secrets() {
  for node in http://localhost:8200 http://localhost:8200 http://localhost:8200; do
    export VAULT_ADDR=$node
    load_token
    vault kv get data/myapp/config
  done
}


