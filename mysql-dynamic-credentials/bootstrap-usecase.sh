#!/usr/bin/zsh

# Unset out current status of the Environment Variables
unset MYSQL_ROOT_PASSWORD
unset MYSQL_DATABASE

# Set envrionment variables
export MYSQL_ROOT_PASSWORD=root
export MYSQL_DATABASE=my_app

# Pull container images
docker pull mysql/mysql-server:5.7

# Start MySQL
echo "---STARTING MYSQL5.7 CONTAINER---"
if [ "$(docker ps -q -f name=mysql5.7)" ]; then
  echo "mysql 5.7 container is running"
  docker container rm -f mysql5.7 
  sleep 5
  docker volume rm app-data
  sleep 3 
fi

docker run --name mysql5.7 --network mynetwork \
  -v app-data:/var/lib/mysql \
  -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
  -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
  -p 3306:3306 \
  -d mysql/mysql-server:5.7.21
# Sleep required for MySQL to be in a ready state with app-data volume
sleep 15
# Create an application service account 
alias mysql="docker exec -it mysql5.7 mysql"
mysql -u root -p'root' -e "CREATE USER 'dbsvc1'@'%' IDENTIFIED BY 'dbsvc1';"
mysql -u root -p'root' -e "GRANT INSERT,SELECT,UPDATE,DELETE ON my_app.* TO 'dbsvc1'@'%';"
# Create Vault servcie account for configuration of database secrets engine
mysql -u root -proot -e "CREATE USER 'vaultadmin'@'%' IDENTIFIED BY 'vaultadmin';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;"

terraform init
terraform apply -auto-approve

docker run --network mynetwork --name transit-app-example \
  -p 5000:5000 \
  -e VAULT_ADDR=http://172.19.0.2:8200 \
  -e VAULT_DATABASE_CREDS_PATH=demo-databases/creds/db-user-readwrite \
  -e VAULT_NAMESPACE= \
  -e VAULT_TOKEN=root \
  -e VAULT_TRANSFORM_PATH=transform \
  -e VAULT_TRANSFORM_MASKING_PATH=masking/transform \
  -e VAULT_TRANSIT_PATH=transit \
  -e MYSQL_ADDR=172.19.0.3 \
  -d assareh/transit-app-example:latest