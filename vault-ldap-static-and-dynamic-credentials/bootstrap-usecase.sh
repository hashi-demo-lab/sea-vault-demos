#!/bin/zsh

# Define variables
#namespace="my-vault-demo"
#LDAP_ORGANISATION="engineers"
#LDAP_DOMAIN="hashibank.com"
#LDAP_ADMIN_PASSWORD="admin"

# Apply Kubernetes YAML file for MySQL deployment
kubectl apply -f ./kubernetes_config/ldap.yaml

# Wait for ldap deployment to be ready
sleep 20

kubectl exec -it vault-dc1-0 -- /bin/sh
vault login 
vault secrets enable ldap

vault write ldap/config \
    binddn=cn=admin,dc=hashibank,dc=com \
    bindpass=admin \
    url=ldap://ldap-service


vault write ldap/static-role/hashicorp \
    dn='cn=alice,ou=users,dc=hashibank,dc=com' \
    username='alice' \
    rotation_period="10s"



vault read ldap/static-cred/hashicorp
# 
#kubectl exec -it ldap-deployment-6d49d54449-vd7zf -c ldap-container -- ldapadd -cxD "cn=admin,dc=example,dc=org" -w admin <<EOF dn: ou=groups,dc=example,dc=org objectClass: organizationalunit objectClass: top ou: groups description: groups of users dn: ou=users,dc=example,dc=org objectClass: organizationalunit objectClass: top ou: users description: users dn: cn=dev,ou=groups,dc=example,dc=org objectClass: groupofnames objectClass: top description: testing group for dev cn: dev member: cn=alice,ou=users,dc=example,dc=org member: cn=aaron,ou=users,dc=example,dc=org dn: cn=manager,ou=groups,dc=example,dc=org objectClass: groupofnames objectClass: top description: testing group for dev cn: manager member: cn=raymond,ou=users,dc=example,dc=org dn: cn=alice,ou=users,dc=example,dc=org objectClass: person objectClass: top cn: alice sn: lee memberOf: cn=dev,ou=groups,dc=example,dc=org userPassword: password123 dn: cn=aaron,ou=users,dc=example,dc=org objectClass: person objectClass: top cn: aaron sn: villa memberOf: cn=dev,ou=groups,dc=example,dc=org userPassword: password123 dn: cn=raymond,ou=users,dc=example,dc=org objectClass: person objectClass: top cn: raymond sn: goh memberOf: cn=manager,ou=groups,dc=example,dc=org userPassword: password123 dn: cn=vault,ou=users,dc=example,dc=org objectClass: person objectClass: top cn: vault sn: vault memberOf: cn=manager,ou=groups,dc=example,dc=org userPassword: vault EOF
#kubectl exec -it ldap-deployment-6c59f748fc-298v8 -c ldap-container -- 'ldapadd -cxD "cn=admin,dc=hashibank,dc=com" -w admin <<EOF dn: ou=groups,dc=hashibank,dc=com objectClass: organizationalunit objectClass: top ou: groups description: groups of users dn: ou=users,dc=hashibank,dc=com objectClass: organizationalunit objectClass: top ou: users description: users dn: cn=dev,ou=groups,dc=hashibank,dc=com objectClass: groupofnames objectClass: top description: testing group for dev cn: dev member: cn=alice,ou=users,dc=hashibank,dc=com member: cn=aaron,ou=users,dc=hashibank,dc=com dn: cn=manager,ou=groups,dc=hashibank,dc=com objectClass: groupofnames objectClass: top description: testing group for dev cn: manager member: cn=raymond,ou=users,dc=hashibank,dc=com dn: cn=alice,ou=users,dc=hashibank,dc=com objectClass: person objectClass: top cn: alice sn: lee memberOf: cn=dev,ou=groups,dc=hashibank,dc=com userPassword: password123 dn: cn=aaron,ou=users,dc=hashibank,dc=com objectClass: person objectClass: top cn: aaron sn: villa memberOf: cn=dev,ou=groups,dc=hashibank,dc=com userPassword: password123 dn: cn=raymond,ou=users,dc=hashibank,dc=com objectClass: person objectClass: top cn: raymond sn: goh memberOf: cn=manager,ou=groups,dc=hashibank,dc=com userPassword: password123 dn: cn=vault,ou=users,dc=hashibank,dc=com objectClass: person objectClass: top cn: vault sn: vault memberOf: cn=manager,ou=groups,dc=hashibank,dc=com userPassword: vault EOF'


# Create Vault service account for configuration of database secrets engine
#kubectl exec -it mysql-0 -- mysql -u root -p'root' -e "CREATE USER '$vaultadmin_username'@'%' IDENTIFIED BY '$vaultadmin_password'; GRANT ALL PRIVILEGES ON *.* TO '$vaultadmin_username'@'%' WITH GRANT OPTION;"

# Terraform Apply
#export VAULT_TOKEN=$dc1_root_token
#tf apply --auto-approve

# Apply Kubernetes YAML file for Transit app deployment
#yq eval '(select(documentIndex == 0) | .spec.template.spec.containers[0].env[] | select(.name == "VAULT_TOKEN").value) |= strenv(VAULT_TOKEN)' -i -P ./kubernetes_config/transit-app.yaml
#sleep 2
#kubectl apply -f ./kubernetes_config/transit-app.yaml

# Forward port for Transit app
#sleep 2
#kubectl port-forward svc/transit-app-svc 5000:80 -n "$namespace"