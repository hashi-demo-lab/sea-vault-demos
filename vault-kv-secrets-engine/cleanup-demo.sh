#!/bin/zsh

# Define variables
namespace="my-vault-demo"
export VAULT_TOKEN=$dc1_root_token

terraform destroy --auto-approve

rm terraform.tfstate
rm terraform.tfstate.backup