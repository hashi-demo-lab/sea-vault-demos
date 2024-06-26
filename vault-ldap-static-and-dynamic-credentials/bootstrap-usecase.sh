#!/bin/zsh
kubectl create secret generic ldap-secrets \
    --from-file=tls.key=./cert/ldap_tls.key \
    --from-file=tls.crt=./cert/ldap_tls.crt
# Apply Kubernetes YAML file
kubectl apply -f ./kubernetes_config/ldap.yaml
# Wait for ldap deployment to be ready
sleep 15
kubectl cp data.ldif my-vault-demo/ldap-0:/tmp/data.ldif -c ldap-container
kubectl exec ldap-0 -c ldap-container -- ldapadd -cxD "cn=admin,dc=hashibank,dc=com" -w admin -f /tmp/data.ldif
terraform apply -auto-approve