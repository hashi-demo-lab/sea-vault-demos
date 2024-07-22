#!/usr/bin/env zsh
# Define variables and set Kubernetes context
namespace="my-vault-demo"
kubectl get namespace "$namespace" >/dev/null 2>&1 || kubectl create namespace "$namespace"
kubectl config set-context --current --namespace="$namespace"

# Clear existing AWS credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Set up the AWS CLI environment variables for Vault's AWS Secrets Engine
if doormat login -f && eval $(doormat aws export --account "${DOORMAT_AWS_USER}"); then
    echo "AWS credentials updated successfully."
    export DOORMAT_USER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')
    export TF_VAR_doormat_user_arn=$DOORMAT_USER_ARN
else
    echo "Error updating AWS credentials. Exiting."
    exit 1
fi

# Update Kubernetes secret with new AWS credentials
kubectl patch secret vault-secrets -p="
{
  \"data\": {
    \"AWS_ACCESS_KEY_ID\": \"$(echo -n "${AWS_ACCESS_KEY_ID}" | base64)\",
    \"AWS_SECRET_ACCESS_KEY\": \"$(echo -n "${AWS_SECRET_ACCESS_KEY}" | base64)\",
    \"AWS_SESSION_TOKEN\": \"$(echo -n "${AWS_SESSION_TOKEN}" | base64)\"
  }
}" && echo "Kubernetes secret updated successfully." || { echo "Failed to update Kubernetes secret. Exiting."; exit 1; }

# Delete old Vault pods so new ones pick up the updated secret
for i in {0..2}; do
  if ! kubectl delete pod "vault-dc1-$i"; then
    echo "Failed to delete pod vault-dc1-$i. Continuing to next pod."
  fi
done

# Unseal Vault pods using the unseal key from the JSON file
sleep 5
output_file="../_setup/vault_keys.json"
UNSEAL_KEY_DC1=$(jq -r '.dc1.unseal_key' "$output_file")
VAULT_TOKEN=$(jq -r '.dc1.root_token' "$output_file")

if [ -z "$UNSEAL_KEY_DC1" ]; then
    echo "Unseal key not found in $output_file. Exiting."
    exit 1
fi

for i in {0..2}; do
  if ! kubectl exec "vault-dc1-$i" -- vault operator unseal "$UNSEAL_KEY_DC1"; then
    echo "Failed to unseal vault-dc1-$i. Continuing to next pod."
  fi
done

sleep 30
terraform apply -auto-approve