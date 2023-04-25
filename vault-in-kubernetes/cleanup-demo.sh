for dc in dc1 dc2; do
    helm uninstall vault-${dc} --namespace=my-vault-demo
    echo "sleeping..."
    sleep 5
  done

for i in {0..2}; do
  kubectl delete pvc data-vault-dc1-$i
done

for i in {0..2}; do
  kubectl delete pvc data-vault-dc2-$i
done

kubectl delete secret my-vault-license --namespace=my-vault-demo
kubectl get all -o wide --namespace=my-vault-demo
kubectl get pvc --namespace=my-vault-demo
lsof -nP -iTCP -sTCP:LISTEN | grep 32000



