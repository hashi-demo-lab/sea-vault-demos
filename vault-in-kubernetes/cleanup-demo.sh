for dc in dc1 dc2; do
    helm uninstall vault-${dc} --namespace=my-vault-demo
    echo "sleeping..."
    sleep 5
  done
  k delete secret vault-secrets 
  kubectl delete pvc --all --namespace=my-vault-demo
  kubectl delete secret my-vault-license --namespace=my-vault-demo
  kubectl get pods -o wide --namespace=my-vault-demo
  lsof -nP -iTCP -sTCP:LISTEN | grep 32000

  kubectl get all --namespace=my-vault-demo
  kubectl get pvc --namespace=my-vault-demo
  kubectl get pods --namespace=my-vault-demo