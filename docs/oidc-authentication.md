# OIDC authentication

Based on : https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth#create-vault-policies

## Create Policies

```
tee manager.hcl <<EOF
# Manage k/v secrets
path "/secret/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
vault policy write manager manager.hcl
tee reader.hcl <<EOF
# Read permission on the k/v secrets
path "/secret/*" {
    capabilities = ["read", "list"]
}
EOF
vault policy write reader reader.hcl
```

## Configure OIDC auth methods

```bash
vault write auth/oidc/config \
  oidc_discovery_url=https://keycloak.raccoon.io/realms/raccoon \
  oidc_client_id="$CLIENT_ID" \
  oidc_client_secret="$CLIENT_SECRET" \
  default_role="reader"
```
