#!/bin/zsh

# Define variables
namespace="my-vault-demo"

# Delete Kubernetes resources
kubectl delete ingress --all -n "$namespace"
kubectl delete issuer --all -n "$namespace"
kubectl delete certificate --all -n "$namespace"
kubectl delete deployment hashibank -n "$namespace"
kubectl delete svc hashibank -n "$namespace"
kubectl delete secret "$ISSUER_SECRET_REF" -n "$namespace"
helm delete ingress-nginx -n "$namespace"
helm delete cert-manager -n "$namespace"