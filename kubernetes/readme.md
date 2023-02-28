# HashiCorp Vault Kubernetes Auth Method

This repository contains instructions and example code to demonstrate how to use the Kubernetes auth method with HashiCorp Vault to retrieve secrets in a Kubernetes environment.

## Prerequisites

- A Kubernetes cluster
- `helm` command line tool
- A running instance of HashiCorp Vault
- `kubectl` command line tool
- `jq` command line tool

## Setup

1. Set the `VAULT_ADDR` environment variable to the address of your running Vault instance:

```export VAULT_ADDR='http://localhost:32000'```

```echo "\n\033[32mRoot token for dc1: $(eval echo "\${dc1_root_token}")\033[0m"```

2. Create a Kubernetes service account that will be used to authenticate to Vault and an application pod. This example uses an `nginx` container:

```kubectl create serviceaccount vault-auth```

```kubectl apply -f pod.yaml```


3. Set up the Vault instance with a key/value secrets engine and a policy:

```cd ../vault-key-value-secrets```

```vault login```

```terraform apply --auto-approve```


## Usage

1. Log in to the Vault container:

    ```kubectl exec -it vault-dc1-0 -- /bin/sh```

    ```vault login```

2. Enable the Kubernetes auth method:

    ```vault auth enable kubernetes```

3. Configure the Kubernetes auth method to use the Vault service account token, Kubernetes URL, and API CA certificate:

    ```vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt```

4. Create an AppRole binding a service account `vault-auth` and attaching the Vault policy. This allows any pod with that service account to request secrets under `demo-aarons-access`:

    ```vault write auth/kubernetes/role/webapp bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=demo-aarons-access ttl=72h```

5. Retrieve a Vault secret from the application container using JWT:

```kubectl exec -it vault-client -- /bin/sh```

```jwt_token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)```

```curl --request POST --data '{"jwt": "'$jwt_token'", "role": "webapp"}' http://10.1.2.192:8200/v1/auth/kubernetes/login | jq -r '.auth.client_token'```

export VAULT_TOKEN=<insert_token_here>

```curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://10.1.2.192:8200/v1/demo-key-value/data/aarons-secrets | jq -r '.data'```


## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.
