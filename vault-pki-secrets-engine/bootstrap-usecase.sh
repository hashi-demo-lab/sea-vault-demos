#!usr/bin/zsh

helm install cert-manager jetstack/cert-manager --namespace my-vault-demo --version v1.11.0 --set installCRDs=true

export TF_VAR_token_reviewer_jwt=$(kubectl exec vault-dc1-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d '\n\r')
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d)

terraform apply --auto-approve

vault login $VAULT_TOKEN  
vault read -field=certificate demo-pki-root/cert/ca > rootCA.pem
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "./RootCA.pem"

kubectl apply -f ./kubernetes_config/hashibank.yaml
kubectl create serviceaccount issuer
kubectl apply -f ./kubernetes_config/issuer-secret.yaml 
kubectl apply -f ./kubernetes_config/vault-issuer.yaml
kubectl apply -f ./kubernetes_config/demo_hashibank_com_cert.yaml
kubectl apply -f ./kubernetes_config/ingress.yaml