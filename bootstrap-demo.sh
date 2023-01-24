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
docker run -d --rm --network mynetwork --name vault-enterprise --cap-add=IPC_LOCK \
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
  docker volume rm app-data
  sleep 3 
fi

docker run --name mysql5.7 --network mynetwork \
  -v app-data:/var/lib/mysql \
  -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
  -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
  -p 3306:3306 \
  -d mysql/mysql-server:5.7.21
#sleep required for MySQL to be in a ready state for command execution
sleep 10

# Run Terraform to configure Vault back to a good state
cd aws-dynamic-workload-identity-vault-customhooks
terraform init
terraform apply -auto-approve -var doormat_user_arn=$DOORMAT_USER_ARN