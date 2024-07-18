#!/bin/zsh

# Define variables
namespace="my-vault-demo"

for dc in dc1 dc2; do
    helm uninstall vault-${dc} -n "$namespace"
    echo "sleeping..."
    sleep 5
  done

for i in {0..2}; do
  kubectl -n "$namespace" delete pvc data-vault-dc1-$i
  kubectl -n "$namespace" delete pvc audit-vault-dc1-$i
done

for i in {0..2}; do
  kubectl -n "$namespace" delete pvc data-vault-dc2-$i
  kubectl -n "$namespace" delete pvc audit-vault-dc2-$i
done

kubectl delete secret vault-secrets -n "$namespace"
helm uninstall ingress-nginx