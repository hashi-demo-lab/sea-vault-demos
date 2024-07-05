#!/usr/bin/zsh

# Helm installation for cert-manager
helm install cert-manager jetstack/cert-manager --namespace my-vault-demo --version v1.11.0 --set installCRDs=true

# Set environment variables
export TF_VAR_token_reviewer_jwt=$(kubectl exec vault-dc1-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr -d '\n\r')
export TF_VAR_kubernetes_ca_cert=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d)

# Apply Terraform configurations
terraform apply --auto-approve

# Vault login and configuration
vault login $VAULT_TOKEN  
vault read -field=certificate demo-pki-root/cert/ca > rootCA.pem
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "./RootCA.pem"

# Apply other configurations
kubectl apply -f ./kubernetes_config/hashibank.yaml
kubectl create serviceaccount issuer-v2
kubectl apply -f ./kubernetes_config/issuer-secret.yaml 

# Encode the CA certificate using macOS-specific base64 command
ca_cert_base64=$(base64 -i ../vault-in-kubernetes/cert/kubernetes-ca.crt)

# Prepare and apply the Issuer manifest with the encoded CA certificate
sed "s|{{CA_BUNDLE}}|$ca_cert_base64|g" ./kubernetes_config/vault-issuer-template.yaml > ./kubernetes_config/vault-issuer.yaml
kubectl apply -f ./kubernetes_config/vault-issuer.yaml

kubectl apply -f ./kubernetes_config/demo_hashibank_com_cert.yaml
kubectl apply -f ./kubernetes_config/ingress.yaml