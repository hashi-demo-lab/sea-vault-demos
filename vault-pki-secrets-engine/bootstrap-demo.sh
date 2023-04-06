#!usr/bin/zsh
kubectl config set-context --current --namespace=my-vault-demo

helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace my-vault-demo
helm install cert-manager jetstack/cert-manager --namespace my-vault-demo --version v1.11.0 --set installCRDs=true

export VAULT_ADDR='http://localhost:32000'
export VAULT_TOKEN=$dc1_root_token
export TF_VAR_token_reviewer_jwt=$(kubectl exec vault-dc1-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d '\n\r')
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d)
tf init -upgrade
terraform apply --auto-approve

kubectl create deployment demo --image=gcr.io/google-samples/hello-app:2.0 --port=8080
kubectl expose deployment demo
kubectl create serviceaccount issuer
kubectl apply -f ./kubernetes_config/issuer-secret.yaml 
export ISSUER_SECRET_REF=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("issuer-token-")).name')
kubectl apply --filename ./kubernetes_config/vault-issuer.yaml
kubectl apply --filename ./kubernetes_config/demo_example_com_cert.yaml
kubectl apply --filename ./kubernetes_config/ingress.yaml