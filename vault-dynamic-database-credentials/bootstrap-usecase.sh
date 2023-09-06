#!/bin/zsh

# Define variables
namespace="my-vault-demo"
mysql_pod="mysql-0"
mysql_username="root"
mysql_password="root"
app_database="my_app"
dbsvc1_username="dbsvc1"
dbsvc1_password="dbsvc1"
vaultadmin_username="vaultadmin"
vaultadmin_password="vaultadmin"

# Apply Kubernetes YAML file for MySQL deployment
kubectl apply -f ./kubernetes_config/mysql.yaml

# Wait for MySQL deployment to be ready
sleep 20

# Create MySQL user and grant permissions for application service account
kubectl exec -it mysql-0 -- mysql -u root -p'root' -e "CREATE USER 'dbsvc1'@'%' IDENTIFIED BY 'dbsvc1'; GRANT INSERT, SELECT, UPDATE, DELETE ON $app_database.* TO '$dbsvc1_username'@'%';"

# Create Vault service account for configuration of database secrets engine
kubectl exec -it mysql-0 -- mysql -u root -p'root' -e "CREATE USER '$vaultadmin_username'@'%' IDENTIFIED BY '$vaultadmin_password'; GRANT ALL PRIVILEGES ON *.* TO '$vaultadmin_username'@'%' WITH GRANT OPTION;"

# Terraform Apply
export VAULT_TOKEN=$dc1_root_token
tf apply --auto-approve

# Apply Kubernetes YAML file for Transit app deployment
yq eval '(select(documentIndex == 0) | .spec.template.spec.containers[0].env[] | select(.name == "VAULT_TOKEN").value) |= strenv(VAULT_TOKEN)' -i -P ./kubernetes_config/transit-app.yaml
sleep 2
kubectl apply -f ./kubernetes_config/transit-app.yaml

terraform apply -auto-approve

# Forward port for Transit app
#sleep 2
#kubectl port-forward svc/transit-app-svc 5000:80 -n "$namespace"