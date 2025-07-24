# Vault Certificate

## Goals

Generate valid certificates with the following structures:

* Root CA: One CA to dominate all.
    * Client CA: Intermediate CA made to have multiple valid certs for mTls
        * Client User cert: Certificate used by dev to access Vault API
        * Client Host cert: Certificate used by server to connect to Vault
    * TLS certificate: Certificate for vault instance.

## Commands

### Create directories
```
mkdir -p certs/private \
    certs/certs \
    certs/crl \
    certs/csr \
    certs/newcerts

echo 1000 > certs/serial
echo 1000 > certs/crlnumber
```

### Root certs

```bash
openssl genrsa -aes256 -out private/ca.key 4096
# pass : test-pwd
chmod 400 private/ca.key
```

Create root CA
```
openssl req -config openssl.cnf -key private/ca.key -new -x509 \
    -days 7300 -sha256 -extensions v3_ca -out certs/ca.crt
chmod 444 certs/ca.crt
```

### Intermediate CA

```bash
openssl genrsa -aes256 -out private/intermediate.key 4096
# Cert sign request
openssl req -config intermediate.openssl.cnf -new -sha256 \
    -key private/intermediate.key \
    -out csr/intermediate.csr
# sign the certificate
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 -in csr/intermediate.csr \
    -out certs/intermediate.crt
```

Verification
```bash
openssl verify -CAfile certs/ca.crt certs/intermediate.crt
```

Create the certificate chain file:
```bash
cat certs/intermediate.crt certs/ca.crt > ca-chain.crt
chmod 4444 ca-chain.crt
```

### Generate server and Client certs

#### server certs

```
openssl genrsa -out private/vault.com.key 2048
chmod 400 private/example.com.key.pem
# Create the request
openssl req -config intermediate.openssl.cnf \
    -key private/vault.com.key \
    -new -sha256 -out csr/vault.com.csr \
    -addext "subjectAltName = DNS:localhost,DNS:www.vault.test"
# Sign the cert
openssl ca -config intermediate.openssl.cnf -extensions server_cert \
    -days 375 -notext -md sha256 -in csr/vault.com.csr \
    -out certs/vault.com.crt
```

#### Client cert

```
openssl genrsa -out private/client.key 2048
chmod 400 private/client.key.pem
# Create the request
openssl req -config intermediate.openssl.cnf \
    -key private/client.key \
    -new -sha256 -out csr/client.csr
# Sign the cert
openssl ca -config intermediate.openssl.cnf -extensions usr_cert \
    -days 375 -notext -md sha256 -in csr/client.csr \
    -out certs/client.crt
```


# Questions ?

Possibility to group both config change the CA part depending of the need ?
