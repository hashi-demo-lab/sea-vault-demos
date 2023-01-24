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

# Pull container images
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
docker run -d --rm --name vault-enterprise --network mynetwork --cap-add=IPC_LOCK \
  -e "VAULT_DEV_ROOT_TOKEN_ID=${VAULT_TOKEN}" \
  -e "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${VAULT_PORT}" \
  -e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -e "VAULT_LICENSE"=${VAULT_LICENSE} \
  -p ${VAULT_PORT}:${VAULT_PORT} \
hashicorp/vault-enterprise:latest

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

# Run Terraform to configure Vault back to a good state
cd aws-dynamic-workload-identity-vault-customhooks
terraform init
terraform apply -auto-approve -var doormat_user_arn=$DOORMAT_USER_ARN

cd ../mysql-dynamic-credentials
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