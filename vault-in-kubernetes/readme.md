# HashiCorp Vault Kubernetes Auth Method

This repository contains instructions and example code to demonstrate how to use the Kubernetes auth method with HashiCorp Vault to retrieve secrets in a Kubernetes environment.
## Prerequisites

- A Kubernetes cluster
- `helm` command line tool
- A running instance of HashiCorp Vault
- `kubectl` command line tool
- `jq` command line tool
- `aws` CLI for AWS integration
- `doormat` utility for AWS credentials
- A certificate and private key stored within the /cert dir (openssl is the easiest solution) 

* aws cli
* jq
* [Doormat](https://docs.prod.secops.hashicorp.services/doormat/cli/) - command line tool must be installed and configured with appropriate credentials
* [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)

```sh
# pre-requisite
brew install helm
brew install jq
brew install awscli
brew install kubectl
```
### Install ingress controller first

   `helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace my-vault-demo`

   `export VAULT_ADDR='http://vault-dc1.hashibank.com:443'`


## Deploy

Run the bootstrap-demo.sh script. This will:

1. Unset any existing AWS environment variables.
2. Set up the AWS CLI Environment variables so that Vault can use them for setting up the AWS Secrets Engine.
3. Create a Kubernetes namespace and switch the current context to it.
4. Set up a Kubernetes secret for passing into the helm chart.
5. Deploy ingress-nginx.
6. Deploy Vault via the Helm chart and initialize it.


```sh
# run bootstrap for doormat creds and pod deployment
zsh ./bootstrap-demo.sh 
```
## Other configuration

2. Create a Kubernetes service account that will be used to authenticate to Vault and an application pod. This example uses an `nginx` container:

   `kubectl create serviceaccount vault-auth`

   `kubectl apply -f pod.yaml`

3. Set up the Vault instance with a key/value secrets engine and a policy:

   `cd ../vault-kv-secrets-engine`

   `vault login`

   `terraform apply --auto-approve`

## Usage

1. Log in to the Vault container:

   `kubectl exec -it vault-dc1-0 -- /bin/sh`

   `vault login`

2. Enable the Kubernetes auth method:

   `vault auth enable kubernetes`

3. Configure the Kubernetes auth method to use the Vault service account token, Kubernetes URL, and API CA certificate:

   `vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`

4. Create an AppRole binding a service account `vault-auth` and attaching the Vault policy. This allows any pod with that service account to request secrets under `demo-aarons-access`:

   `vault write auth/kubernetes/role/webapp bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=demo-aarons-access ttl=72h`

5. Retrieve a Vault secret from the application container using JWT and cURL :

   `vault_ip=$(kubectl get pod vault-dc1-0 --output=json | jq -r '.status.podIP')`

   `jwt_token=$(kubectl exec -it vault-client -- sh -c 'cat /var/run/secrets/kubernetes.io/serviceaccount/token')`

   `response=$(kubectl exec -it vault-client -- sh -c "curl --request POST --data '{\"jwt\": \"$jwt_token\", \"role\": \"webapp\"}' http://$vault_ip:8200/v1/auth/kubernetes/login")`

   `client_token=$(echo "$response" | jq -r '.auth.client_token')`

   `data=$(kubectl exec -it vault-client -- sh -c 'curl -H "X-Vault-Token: '"$client_token"'" -X GET http://$vault_ip:8200/v1/demo-key-value/data/aarons-secrets')`

6. Retrieve a Vault secret from the application container using Vault Agent

   `kubectl apply -f pod2.yaml`

   `kubectl describe pod webapp`

   `kubectl logs webapp -c vault-agent-init`

   `kubectl exec -it webapp -c nginx -- cat /vault/secrets/config.txt`

## Other helpful commands

```sh
  kubectl apply -f rbac.yaml
  kubectl apply -f pod2.yaml
  kubectl describe pod webapp
  kubectl logs webapp -c vault-agent-init
```

## Troubleshooting purposes

```sh
  helm list
  for i in {0..2} ; do kubectl exec vault-${dc}-$i -- vault status ; done
  kubectl describe pod vault-${dc}
  kubectl logs vault-${dc}-0
  kubectl exec -it vault-${dc}-0 -- /bin/sh
  vault operator raft list-peers (need to authenticate to vault first)  
```

## Cleanup

```sh
  for dc in dc1 dc2; do
    helm uninstall vault-${dc} --namespace=my-vault-demo
    echo "sleeping..."
    sleep 5
  done
  kubectl delete pvc --all --namespace=my-vault-demo
  kubectl delete secret my-vault-license --namespace=my-vault-demo
  kubectl get pods -o wide --namespace=my-vault-demo
  lsof -nP -iTCP -sTCP:LISTEN | grep 32000

  kubectl get all --namespace=my-vault-demo
  kubectl get pvc --namespace=my-vault-demo
  kubectl get pods --namespace=my-vault-demo

```

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.


## Set required environment variables
Certain unique environment variables are required prior:

# Terraform Cloud Agent Authentication
* echo 'export TFC_AGENT_TOKEN=<>' >> ~/.zshenv


* echo 'export DOORMAT_AWS_USER=<>' >> ~/.zshenv

# Vault Enterprise License Key
* echo 'export VAULT_LICENSE=<>' >> ~/.zshenv

# For Azure authentiation
* echo 'export ARM_CLIENT_ID=<>' >> ~/.zshenv
* echo 'export ARM_CLIENT_SECRET=<>' >> ~/.zshenv
* echo 'export ARM_SUBSCRIPTION_ID=<>' >> ~/.zshenv
* echo 'export ARM_TENANT_ID=<>' >> ~/.zshenv

# Terraform cloud API token

* echo 'export TFE_TOKEN=<>' >> ~/.zshenv

# Usage

```sh { closeTerminalOnSuccess=false }
. ./bootstrap-demo.sh
```


# Clean up
```# Clean up steps
   kubectl delete all --all -n my-vault-demo
   kubectl delete pvc --all
   kubectl delete roles --all
   kubectl get clusterroles | grep '^cert-' | awk '{print $1}' | xargs kubectl delete clusterrole
   kubectl delete clusterroles ingress-nginx vault-dc1-agent-injector-clusterrole vault-dc2-agent-injector-clusterrole
   kubectl get clusterrolebinding | grep '^cert-' | awk '{print $1}' | xargs kubectl delete
   kubectl delete $(kubectl get clusterrolebinding -o=name | grep cert-)
   kubectl delete $(kubectl get clusterrolebinding -o=name | grep vault)

   kubectl get crds -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '\.cert-manager\.io$' | xargs kubectl delete crds 
   kubectl delete namespace my-vault-demo
```
