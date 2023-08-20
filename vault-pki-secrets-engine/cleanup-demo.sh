#!/bin/zsh

terraform destroy --auto-approve

# Define variables
namespace="my-vault-demo"

# Delete Kubernetes resources
kubectl delete ingress hashibank-web -n "$namespace"
kubectl delete issuer vault-issuer -n "$namespace"
kubectl delete serviceaccount issuer -n "$namespace"
kubectl delete certificate --all -n "$namespace"
kubectl delete deployment hashibank -n "$namespace"
kubectl delete svc hashibank -n "$namespace"
kubectl delete secret demo-hashibank-com-tls