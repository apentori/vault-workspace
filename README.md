# Vault - Test environment

## Description

This repository is made to test Vault in different setups with mTLS enable
* Single Instance
* Cluster Mode



## Single Instance
```
+-----------+
|  Root CA  |
++----------+
 |
 |    +-------------+
 +--->|  Client CA  |
      +-----------+-+  +----------------+
                  +--->|  User Certs    |
                  |    +----------------+
                  |    +----------------+
                  +--->|  TLS Certs     |
                       +----------------+
```

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


#### Cluster mode

```
+-----------+
|  Root CA  |
++----------+
 |
 |    +-------------+
 +--->|  Client CA  |
      +-----------+-+  +----------------+
                  +--->|  User Certs    |
                  |    +----------------+
                  |    +----------------+
                  +--->|  Cluster Certs |
                  |    +----------------+
                  |    +----------------+
                  +--->|  TLS Certs     |
                       +----------------+
```

* Generate new certificate for the Cluster mode
* Run multiple Vault instance in Raft Cluster mode

