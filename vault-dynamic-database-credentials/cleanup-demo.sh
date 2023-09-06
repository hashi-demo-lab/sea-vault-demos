#!/bin/zsh

# Define variables
namespace="my-vault-demo"
export VAULT_TOKEN=$dc1_root_token

# Delete Kubernetes resources
kubectl delete -f ./kubernetes_config/transit-app.yaml
kubectl delete -f ./kubernetes_config/mysql.yaml

terraform destroy --auto-approve