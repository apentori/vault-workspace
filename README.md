# Vault - Test environment

## Description

This repository is made to test Vault in different setup


## Tests

#### Certificates generations

Generate the certificate following the process [Certificate Generation and mTls](./docs/certificates-generation.md)

Test differents combinations of certicates by changing the docker-compose volumes and the envirionment variables

Unseal the Vault and create secrets in the vault:
```bash
vault operator init -key-shares=1 -key-threshold=1

vault operator unseal $UNSEAL_KEY
EXPORT VAULT_TOKEN=<...>
vault secrets enable -path secret kv-v2
vault kv put -mount=secret secrets/test aaa=bbb
vault kv get -mount=secret secrets/test
```
