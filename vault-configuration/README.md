# terraform-template

This is a bootstrap script to setup Vault Enteprise and TFC Agents then refresh doormat cred and setup


# Pre-requisites

## set environment variables

echo 'export TFC_AGENT_TOKEN=<>' >> ~/.zshenv
echo 'export DOORMAT_AWS_USER=<>' >> ~/.zshenv
echo 'export VAULT_LICENSE=<>' >> ~/.zshenv

## run bootstrap

zsh bootstrap-demo.sh


