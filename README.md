# Bootstrap 

This repository contains the necessary files to build and configure:
- HashiCorp Vault Enterprise
- Terraform Cloud Agent

The objective of this repository is to to create an end-to-end orchestration demo environment that allows for members of the SEA team to 
demonstrate the capabilities of using Vault Enterprise and the TFC Agent.

The demo environment was created with the following principles in mind
- Require no credentials to be stored in Terraform Cloud
- Easily understandable and demonstrable for the intended audience, whether it be for internal stakeholders or external clients.
- Easliy redeployable with a principle of being idempotant
- Low impact on cost for running a demo environment


The entry point into creating this demo enviornment is the bootstrap script (```bootstrap-demo.sh```) which is used to set up the demo. 

# What the script does

1. Unsets current environment variables
2. Sets environment variables for Vault, including VAULT_PORT, VAULT_TOKEN, VAULT_ADDR, ROLE_NAME, and TFC_AGENT_NAME
3. Pulls the latest version of cloudbrokeraz/tfc-agent-custom and hashicorp/vault-enterprise Docker images
4. Starts a TFC Agent container if one is not already running
    - This is a Custom TFC Agent with custom hooks, using workload identity token to retreive and revoke credentials dynamically using Vault AWS Secrets engine (see below for more detail)
5. Runs doormat login and exports credentials to be used by Vault Enterprise
6. If a Vault container is already running, stops and removes it
7. Starts a new Vault container, passing in the necessary environment variables and ports
8. Sleeps for 5 seconds to allow the Vault container to start up
9. runs the terraform apply command to configure Vault with
    - K/V secrets engine & AWS secrets engine, 
    - Creates a policy granting access to both engines
    - Configures the JWT auth method (this is used for the OIDC trust using workload identity between a TFC workspace and the Vault-Enterprise container)

# Pre-requisites

## Software

* [Doormat](https://docs.prod.secops.hashicorp.services/doormat/cli/) - command line tool must be installed and configured with appropriate credentials
* [Docker](https://www.docker.com/products/docker-desktop/)

## Licenses

* A valid Vault license key

## Set required environment variables

* echo 'export TFC_AGENT_TOKEN=<>' >> ~/.zshenv
* echo 'export DOORMAT_AWS_USER=<>' >> ~/.zshenv
* echo 'export DOORMAT_AZURE_USER=<>' >> ~/.zshenv
* echo 'export DOORMAT_GCP_USER=<>' >> ~/.zshenv
* echo 'export VAULT_LICENSE=<>' >> ~/.zshenv

# Usage

```zsh bootstrap-demo.sh```

# Notes

* This script is intended for demo purposes only and is not recommended for production use
* The script uses docker kill to stop and remove the Vault container. Be aware that this command will remove any data manually stored in the container.