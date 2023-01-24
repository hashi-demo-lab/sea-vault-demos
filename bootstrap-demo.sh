#!/usr/bin/zsh
# Unset out current status of the Environment Variables
unset VAULT_PORT
unset VAULT_TOKEN
unset VAULT_ADDR
unset ROLE_NAME
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TFC_AGENT_NAME
unset MYSQL_ROOT_PASSWORD
unset MYSQL_DATABASE

# Set envrionment variables
export VAULT_PORT=8200
export VAULT_TOKEN=root
export VAULT_ADDR=http://localhost:${VAULT_PORT}
export TFC_AGENT_NAME=tfc-agent
export MYSQL_ROOT_PASSWORD=root
export MYSQL_DATABASE=my_app

# Set up the AWS CLI Env variables so that Vault can use them for setting up the AWS Secrets Engine
doormat login -f && eval $(doormat aws export --account ${DOORMAT_AWS_USER})
DOORMAT_USER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')

echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
echo DOORMAT_USER_ARN:  $DOORMAT_USER_ARN

#pull container images
docker pull cloudbrokeraz/tfc-agent-custom:latest
docker pull hashicorp/vault-enterprise:latest
docker pull mysql/mysql-server:5.7

# Start Terraform Cloud Agent 
echo "---STARTING THE TFC-AGENT CONTAINER---"
if [ "$(docker ps -q -f name=$TFC_AGENT_NAME)" ]; then
  echo "tfc-agent container is running"
else
  docker run -d --rm --name tfc-agent --network host --cap-add=IPC_LOCK \
    -e "TFC_AGENT_TOKEN=${TFC_AGENT_TOKEN}" \
    -e "TFC_AGENT_NAME=${TFC_AGENT_NAME}" \
  cloudbrokeraz/tfc-agent-custom:latest
fi

# Start Vault Enterpise
echo "---STARTING HASHICORP VAULT CONTAINER---"
if [ "$(docker ps -q -f name=vault-enterprise)" ]; then
  echo "Container is running"
  docker kill vault-enterprise
  sleep 3
fi
docker run -d --rm --name vault-enterprise --cap-add=IPC_LOCK \
  -e "VAULT_DEV_ROOT_TOKEN_ID=${VAULT_TOKEN}" \
  -e "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${VAULT_PORT}" \
  -e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -e "VAULT_LICENSE"=${VAULT_LICENSE} \
  -p ${VAULT_PORT}:${VAULT_PORT} \
hashicorp/vault-enterprise:latest

 # -e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
 # -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
 # -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
# Start MySQL
echo "---STARTING MYSQL5.7 CONTAINER---"
if [ "$(docker ps -q -f name=mysql5.7)" ]; then
  echo "mysql 5.7 container is running"
  docker kill mysql5.7
  sleep 3
fi

docker run -d --rm --name mysql5.7  \
 -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
 -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
 -p 3306:3306 \
 mysql/mysql-server:5.7
#sleep required for MySQL to be in a ready state for command execution
sleep 10

# Execute mysql commands to populate database and create accounts
alias mysql="docker exec -it mysql5.7 mysql"

#Display existing database users
mysql -u root -p$MYSQL_ROOT_PASSWORD \
  -e "select Host,User from mysql.user;"

#Create sample data set in mysql "app"
mysql -u root -p$MYSQL_ROOT_PASSWORD \
  -e "CREATE TABLE IF NOT EXISTS my_app.customers (
  cust_no int(11) NOT NULL AUTO_INCREMENT,
  birth_date varchar(255) NOT NULL,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  create_date varchar(255) NOT NULL,
  social_security_number varchar(255) NOT NULL,
  address varchar(255) NOT NULL,
  salary varchar(255) NOT NULL,
  PRIMARY KEY (cust_no)
  ) ENGINE=InnoDB;"

mysql -u root -proot \
  -e "INSERT IGNORE into my_app.customers VALUES
  (2, '3/14/69', 'Larry', 'Johnson', '2020-01-01T14:49:12.301977', '360-56-6750', 'Tyler, Texas', '7000000'),
  (40, '11/26/69', 'Shawn', 'Kemp', '2020-02-21T10:24:55.985726', '235-32-8091', 'Elkhart, Indiana', '15000000'),
  (34, '2/20/63', 'Charles', 'Barkley', '2019-04-09T01:10:20.548144', '531-72-1553', 'Leeds, Alabama', '9000000');
  "

#Create application service account for application access
mysql -u root -proot \
  -e "CREATE USER 'dbsvc1'@'%' IDENTIFIED BY 'dbsvc1';"
mysql -u root -proot \
  -e "GRANT INSERT,SELECT,UPDATE,DELETE ON my_app.* TO 'dbsvc1'@'%';"

#View sample data populated in the database
#mysql -u dbsvc1 -pdbsvc1 -e "SELECT * FROM my_app.customers"

#Create Vault account for connecting to mysql database
mysql -u root -proot \
  -e "CREATE USER 'vaultadmin'@'%' IDENTIFIED BY 'vaultadmin';"
mysql -u root -proot \
  -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;"

# Run Terraform to configure Vault back to a good state
cd aws-dynamic-workload-identity-vault-customhooks
terraform init
terraform apply -auto-approve -var doormat_user_arn=$DOORMAT_USER_ARN