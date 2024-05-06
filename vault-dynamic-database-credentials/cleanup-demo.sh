#!/bin/zsh

# Define variables
namespace="my-vault-demo"
export VAULT_TOKEN=$dc1_root_token

# Delete Kubernetes resources
kubectl delete -f ./kubernetes_config/transit-app.yaml
kubectl delete -f ./kubernetes_config/mysql.yaml
kubectl delete -f ./kubernetes_config/app-hashibank-com-cert.yaml

terraform destroy --auto-approve

terraform destroy --auto-approve

rm terraform.tfstate
rm terraform.tfstate.backup