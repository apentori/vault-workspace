# Running the Vault as a Raft Cluster

## Steps

* Generate all the certificates following the [certificates generation documentations](./certificates-generation.md)
* Run the docker compose [cluster-vault-compose.yml](../cluster-vault-compose.yml): `docker compose -f cluster-vault-compose up -d`
* Init the Cluster by starting the first instance `vault-1`
  ```bash
  export VAULT_ADDR=https://localhost:8200
  vault operator init -key-shares=1 -key-threshold=1
  # This command will give the unseal key and the root token
  vault operator unseal $SEAL_KEY
  # Check the Peer configuration
  export VAULT_TOKEN=$ROOT_TOKEN
  vault operator raft list-peers
  ```
* Unseal the second instance `vault-2`
  ```bash
  export VAULT_ADDR=https://localhost:8300
  vault operator unseal $SEAL_KEY
  ```
  Change the `VAULT_ADDR` to the first instance and verify the Raft peers:
  ```bash
  vault operator raft list-peers
  Node       Address            State       Voter
  ----       -------            -----       -----
  node-01    178.27.1.5:8201    leader      true
  node-02    178.27.1.6:8201    follower    true
  ```
* Unseal the third instance `vault-3`
  ```bash
  export VAULT_ADDR=https://localhost:8400
  vault operator unseal $SEAL_KEY
  ```
  Change the `VAULT_ADDR` to the first instance and verify the Raft peers:
  ```bash
  vault operator raft list-peers
  Node       Address            State       Voter
  ----       -------            -----       -----
  node-01    178.27.1.5:8201    leader      true
  node-02    178.27.1.6:8201    follower    true
  node-03    178.27.1.7:8201    follower    false
  ```

