#!/bin/zsh
# Define variables
namespace="my-vault-demo"
export TF_VAR_token_reviewer_jwt=$(kubectl exec vault-dc1-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d '\n\r')
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d)

terraform destroy --auto-approve

# Delete Kubernetes resources
kubectl delete ingress hashibank-web-v2 -n "$namespace"
kubectl delete certificate demo-hashibank-com-v2 -n "$namespace"
kubectl delete issuer vault-issuer-v2 -n "$namespace"
kubectl delete secret demo-hashibank-com-tls-v2

kubectl delete serviceaccount issuer-v2 -n "$namespace"

kubectl delete deployment hashibank-v2 -n "$namespace"
kubectl delete svc hashibank-v2 -n "$namespace"

helm uninstall cert-manager 