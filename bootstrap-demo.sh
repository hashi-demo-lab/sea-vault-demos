#!/bin/zsh

# Unset out current status of the Environment Variables
unset VAULT_PORT
unset VAULT_TOKEN
unset VAULT_ADDR
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TFC_AGENT_NAME

# Set envrionment variables
export VAULT_PORT=8200
export VAULT_TOKEN=root
export VAULT_ADDR=http://localhost:${VAULT_PORT}
export TFC_AGENT_NAME=tfc-agent

# Set up the AWS CLI Env variables so that Vault can use them for setting up the AWS Secrets Engine
doormat login -f && eval $(doormat aws export --account ${DOORMAT_AWS_USER})
DOORMAT_USER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')

echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
echo DOORMAT_USER_ARN:  $DOORMAT_USER_ARN

# Docker prep
docker pull cloudbrokeraz/tfc-agent-custom:latest
docker pull hashicorp/vault-enterprise:latest

if [[ "$(docker network ls -q -f name=demo-network)" == "" ]]; then
    echo "Creating demo-network network..."
    docker network create demo-network
else
    echo "'demo-network' network already exists."
fi

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
docker run -d --rm --name vault-enterprise --hostname vault-enterprise  \
  --network demo-network  --cap-add=IPC_LOCK \
  -e "VAULT_DEV_ROOT_TOKEN_ID=${VAULT_TOKEN}" \
  -e "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${VAULT_PORT}" \
  -e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -e "VAULT_LICENSE"=${VAULT_LICENSE} \
  -p ${VAULT_PORT}:${VAULT_PORT} \
hashicorp/vault-enterprise:latest