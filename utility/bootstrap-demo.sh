#!usr/bin/zsh

# Unset out current status of the Environment Variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Set envrionment variables
export VAULT_PORT=8200
export VAULT_TOKEN=root
export VAULT_ADDR=http://localhost:${VAULT_PORT}

# Set up the AWS CLI Env variables so that Vault can use them for setting up the AWS Secrets Engine
doormat login -f && eval $(doormat aws export --account ${DOORMAT_AWS_USER})
DOORMAT_USER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')
export TF_VAR_doormat_user_arn=$DOORMAT_USER_ARN

echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
echo DOORMAT_USER_ARN:  $DOORMAT_USER_ARN

# Docker prep
docker pull hashicorp/vault-enterprise:latest

# Create Docker network
echo "\n\033[32m---CREATING DOCKER NETWORK---\033[0m"
if [[ "$(docker network ls -q -f name=demo-network)" == "" ]]; then
    echo "Creating demo-network network..."
    docker network create demo-network
else
    echo "\033[33mDocker network 'demo-network' network already exists. skipping 'docker network create'.\033[0m"
fi

# Start Vault Enterpise
echo "\n\033[32m---STARTING HASHICORP VAULT CONTAINER---\033[0m"
if docker inspect vault-enterprise &> /dev/null; then
  echo "\033[33mContainer vault-enterprise already exists, killing container and redeploying.\033[0m"
  docker kill vault-enterprise &> /dev/null
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