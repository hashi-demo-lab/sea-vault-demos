#!/bin/zsh

# Define variables
namespace="my-vault-demo"

# Delete Kubernetes resources
kubectl delete -f ./kubernetes_config/ldap.yaml