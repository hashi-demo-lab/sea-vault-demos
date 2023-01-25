#!/usr/bin/zsh

# Unset out current status of the Environment Variables
unset MYSQL_ROOT_PASSWORD
unset MYSQL_DATABASE

# Set envrionment variables
export MYSQL_ROOT_PASSWORD=root
export MYSQL_DATABASE=my_app

# Pull container images
docker pull mysql/mysql-server:5.7
docker pull cloudbrokeraz/app01:latest

# Start MySQL
echo "---STARTING MYSQL CONTAINER---"
if [ "$(docker ps -q -f name=mysql)" ]; then
  echo "mysql 5.7 container is running"
  docker container rm -f mysql
  sleep 5
  docker volume rm app-data
  sleep 3 
fi

docker run --name mysql --hostname mysql --network demo-network \
  -v app-data:/var/lib/mysql \
  -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
  -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
  -p 3306:3306 \
  -d mysql/mysql-server:5.7.21
# Sleep required for MySQL to be in a ready state with app-data volume
sleep 15

# Create an application service account 
alias mysql="docker exec -it mysql mysql"
mysql -u root -p'root' -e "CREATE USER 'dbsvc1'@'%' IDENTIFIED BY 'dbsvc1';"
mysql -u root -p'root' -e "GRANT INSERT,SELECT,UPDATE,DELETE ON my_app.* TO 'dbsvc1'@'%';"

# Create Vault servcie account for configuration of database secrets engine
mysql -u root -proot -e "CREATE USER 'vaultadmin'@'%' IDENTIFIED BY 'vaultadmin';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;"

# Setup database secrets engine
terraform init
terraform apply -auto-approve

# Start app
echo "---STARTING APP CONTAINER---"
if [ "$(docker ps -q -f name=app)" ]; then
  echo "app container is running"
  docker container rm -f app
  sleep 3
fi

docker run --network demo-network --hostname app --name app \
  -p 5000:5000 \
  -e VAULT_ADDR=http://vault-enterprise:8200 \
  -e VAULT_DATABASE_CREDS_PATH=demo-databases/creds/db-user-readwrite \
  -e VAULT_NAMESPACE= \
  -e VAULT_TOKEN=root \
  -e VAULT_TRANSFORM_PATH=demo-transform \
  -e VAULT_TRANSFORM_MASKING_PATH=masking/transform \
  -e VAULT_TRANSIT_PATH=demo-transit \
  -e MYSQL_ADDR=mysql \
  -d cloudbrokeraz/app01:latest