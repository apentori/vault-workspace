#!/usr/bin/env bash
set -euo pipefail

export VAULT_FORMAT=json
# Configuration
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
KEYS_FILE="vault-keys.json"
SECRET_ENGINE_PATH="secret"
SECRET_PATH="secret/data/myapp/config"

export VAULT_ADDR

check_vault_status() {
  echo "==> Checking Vault status at ${VAULT_ADDR}..."
  until vault status > /dev/null 2>&1 || [ $? -eq 2 ]; do
    echo "Waiting for Vault to be reachable..."
    sleep 2
  done
}

init_vault() {
  if [ ! -f "${KEYS_FILE}" ]; then
    echo "==> Initializing Vault..."
    vault operator init -key-shares=1 -key-threshold=1 -format=json > "${KEYS_FILE}"
    echo "Keys saved to ${KEYS_FILE}"
  else
    echo "==> ${KEYS_FILE} already exists. Skipping initialization."
  fi
}

unsealing_nodes() {
  check_vault_status
  echo ""
  echo "=> Unsealing Vault"
  echo ""
  vault operator unseal "${UNSEAL_KEY}" > /dev/null
  sleep 2
  vault status | jq -r '"Vault Status : Initialized \(.initialized), sealed: \(.sealed)"'
  echo ""
  echo "==> Listing secrets engine"
  echo""
  vault secrets list | jq 'keys'
}

echo "-> Initializing Vault 1"
check_vault_status
init_vault

# Extract Root Token and Unseal Key
ROOT_TOKEN=$(jq -r '.root_token' "${KEYS_FILE}")
UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' "${KEYS_FILE}")
export VAULT_TOKEN="${ROOT_TOKEN}"

echo "==> Unsealing Vault 1..."
unsealing_nodes

echo "==> Enabling secret engine '${SECRET_ENGINE_PATH}'..."
if ! vault secrets list -format=json | jq -e ".\"${SECRET_ENGINE_PATH}/\"" > /dev/null; then
  vault secrets enable -path="${SECRET_ENGINE_PATH}" kv-v2
else
  echo "Secret engine '${SECRET_ENGINE_PATH}' is already enabled."
fi

echo "==> Writing secrets to ${SECRET_PATH}..."
vault kv put "${SECRET_PATH}" \
  db_password="SuperSecretPassword123!" \
  test_backup="new" \
  api_key="key-abc-123-xyz" \
  environment="test-upgrade" | jq '.data.created_time'


echo "==> Reading back secrets..."
vault kv get "${SECRET_PATH}" | jq '.data'
