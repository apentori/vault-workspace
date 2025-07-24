# Vault Certificate

## Goals

Generate valid certificates with the following structures:

* Root CA: One CA to dominate all.
    * Client CA: Intermediate CA made to have multiple valid certs for mTls
        * Client User cert: Certificate used by dev to access Vault API
        * Client Host cert: Certificate used by server to connect to Vault
    * TLS certificate: Certificate for vault instance.

## Commands

### Setup workspaces

All certificates will be created in the `certs` directory.

```bash
mkdir -p certs/private \
    certs/certs \
    certs/crl \
    certs/csr \
    certs/newcerts

# Create files for certificates generations
echo 1000 > certs/serial
echo 1000 > certs/crlnumber
touch certs/index.txt
```

Once the directories exist, go to the `certs` directory:


### Root certs

The first step is to create the Root CA. It will be protected by a password.

```bash
openssl genrsa -aes256 -out private/ca.key 4096
# pass : test-pwd
chmod 400 private/ca.key
# Create the Certificate
openssl req -new -x509 \
    -config openssl.cnf \
    -key private/ca.key \
    -days 7300 -sha256 \
    -extensions v3_ca \
    -out certs/ca.crt

chmod 444 certs/ca.crt
```

### Intermediate CA

Then generate an Intermediate CA to sign the Clients and Servers certificate

```bash
# Generate the Private key
openssl genrsa -aes256 -out private/intermediate.key 4096

# Cert sign request
openssl req -new -sha256 \
    -config intermediate.openssl.cnf \
    -key private/intermediate.key \
    -out csr/intermediate.csr

# Sign the certificate
openssl ca -days 3650 -notext -md sha256 \
    -config openssl.cnf \
    -extensions v3_intermediate_ca \
    -in csr/intermediate.csr \
    -out certs/intermediate.crt
```

Verify the certificate validity
```bash
openssl verify -CAfile certs/ca.crt certs/intermediate.crt
```

Create the certificate chain file to group the Root and Intermediate CA:
```bash
cat certs/intermediate.crt certs/ca.crt > ca-chain.crt
```

### Generate server and Client certs

#### Server certs

```
# Generate a Private key
openssl genrsa -out private/server_tls.key 2048
# Create the request
openssl req -new -sha256 \
    -config intermediate.openssl.cnf \
    -key private/server_tls.key \
    -out csr/server_tls.csr \
    -addext "subjectAltName = DNS:localhost,DNS:www.vault.test"
# Sign the cert
openssl ca -days 375 -notext -md sha256 \
    -config intermediate.openssl.cnf \
    -extensions server_cert \
    -in csr/server_tls.csr \
    -out certs/server_tls.crt
```

Verify the certifcate:

```bash
openssl verify -CAfile certs/ca.crt -untrusted certs/intermediate.crt certs/server_tls.crt
openssl verify -CAfile ca-chain.crt certs/server_tls.crt
```

#### Client certs

Generate the client certificate use on the host for the mTLS.

```
# Generate private key
openssl genrsa -out private/client.key 2048

# Create the request
openssl req -new -sha256 \
    -config intermediate.openssl.cnf \
    -key private/client.key \
    -out csr/client.csr

# Sign the cert
openssl ca -days 375 -notext -md sha256 \
    -config intermediate.openssl.cnf \
    -extensions usr_cert \
     -in csr/client.csr \
    -out certs/client.crt
```

```bash
openssl verify -CAfile certs/ca.crt -untrusted certs/intermediate.crt certs/client.crt
openssl verify -CAfile ca-chain.crt certs/client.crt
```


#### Cluster certs

```bash
# Generate private key
openssl genrsa -out private/cluster_client.key 2048

# Create the request
openssl req -new -sha256 \
    -config intermediate.openssl.cnf \
    -key private/cluster_client.key \
    -out csr/cluster_client.csr

# Sign the cert
openssl ca -days 375 -notext -md sha256 \
    -config intermediate.openssl.cnf \
    -extensions usr_cert \
     -in csr/cluster_client.csr \
    -out certs/cluster_client.crt

```

# Questions ?

Possibility to group both config change the CA part depending of the need ?
