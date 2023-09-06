#!/bin/zsh

# Define variables
namespace="my-vault-demo"

terraform destroy --auto-approve

# Delete Kubernetes resources
kubectl delete -f ./kubernetes_config/ldap.yaml
kubectl delete secret ldap-secrets