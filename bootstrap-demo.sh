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

# Set up Vault specific Env variables
# VAULT_LICENSE env variable requires a valid Vault license key
export VAULT_PORT=8200
export VAULT_TOKEN=root
export VAULT_ADDR=http://localhost:${VAULT_PORT}
export TFC_AGENT_NAME=tfc-agent

#pull container images
docker pull cloudbrokeraz/tfc-agent-custom:latest
docker pull hashicorp/vault-enterprise:latest

if [ "$(docker ps -q -f name=$TFC_AGENT_NAME)" ]; then
  echo "tfc-agent container is running"
else
  echo "---starting tfc-agent container---"
  docker run -d --rm --name tfc-agent --network host --cap-add=IPC_LOCK \
-e "TFC_AGENT_TOKEN=${TFC_AGENT_TOKEN}" \
-e "TFC_AGENT_NAME=${TFC_AGENT_NAME}" \
cloudbrokeraz/tfc-agent-custom:latest
fi

# Set up the AWS CLI Env variables so that Vault can use them for setting up the AWS Secrets Engine
doormat login -f && eval $(doormat aws export --account ${DOORMAT_AWS_USER})

echo VAULT_PORT:    $VAULT_PORT
echo VAULT_TOKEN:   $VAULT_TOKEN
echo VAULT_ADDR:    $VAULT_ADDR
echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID

# Deploy Vault in a container rather than on localhost
# passes in the AWS Env variables so that when the TFC agent
# executes the vault-configuration repo (https://github.com/CloudbrokerAz/vault-configuration)
# it has the variables to configure the AWS Secrets Engine correctly
if [ "$(docker ps -q -f name=vault-enterprise)" ]; then
  echo "Container is running"
  docker kill vault-enterprise
  sleep 5
fi

echo "---starting vault container---"
docker run -d --rm --name vault-enterprise --cap-add=IPC_LOCK \
-e "VAULT_DEV_ROOT_TOKEN_ID=${VAULT_TOKEN}" \
-e "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${VAULT_PORT}" \
-e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
-e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
-e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
-e "VAULT_LICENSE"=${VAULT_LICENSE} \
-p ${VAULT_PORT}:${VAULT_PORT} \
hashicorp/vault-enterprise:latest

echo "Starting vault-enterprise"
sleep 5

# Run Terraform to configure Vault back to a good state
cd vault-configuration
terraform init
terraform apply -auto-approve