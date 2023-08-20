#!/bin/zsh
# Define variables
#namespace="my-vault-demo"
#LDAP_ORGANISATION="engineers"
#LDAP_DOMAIN="hashibank.com"
#LDAP_ADMIN_PASSWORD="admin"

kubectl create secret generic ldap-secrets \
    --from-file=tls.key=./cert/ldap_tls.key \
    --from-file=tls.crt=./cert/ldap_tls.crt

# Apply Kubernetes YAML file
kubectl apply -f ./kubernetes_config/ldap.yaml

# Wait for ldap deployment to be ready
sleep 10

kubectl cp data.ldif my-vault-demo/ldap-0:/tmp/data.ldif -c ldap-container
kubectl exec ldap-0 -c ldap-container -- ldapadd -cxD "cn=admin,dc=hashibank,dc=com" -w admin -f /tmp/data.ldif