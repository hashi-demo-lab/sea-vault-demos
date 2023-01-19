# terraform-template

This is a bootstrap script to setup Vault Enteprise and TFC Agents then refresh doormat cred and setup and OIDC trust using workload identity between a TFC workspace and local Vault-Enterprise. This allows for no credentials to be stored in Terraform cloud.

1. Request AWS creds from doormat
2. Setup docker containers for Vault-Enterpise and TFC Agents with Custom Hooks for Vault
3. Configure Vault and establish OIDC trust between workspace identity and Vault role
4. Use Custom Terraform agent with custom hooks and workload identity token to retreive and revoke credentials dynamically

## Pre-requisites

## set environment variables

echo 'export TFC_AGENT_TOKEN=<>' >> ~/.zshenv
echo 'export DOORMAT_AWS_USER=<>' >> ~/.zshenv
echo 'export VAULT_LICENSE=<>' >> ~/.zshenv

## run bootstrap

zsh bootstrap-demo.sh
