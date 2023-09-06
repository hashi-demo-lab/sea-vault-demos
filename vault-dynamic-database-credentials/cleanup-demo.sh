#!/bin/zsh

# Define variables
namespace="my-vault-demo"
export VAULT_TOKEN=$dc1_root_token

terraform destroy --auto-approve

# Delete Kubernetes resources
kubectl delete -f ./kubernetes_config/transit-app.yaml
kubectl delete -f ./kubernetes_config/mysql.yaml