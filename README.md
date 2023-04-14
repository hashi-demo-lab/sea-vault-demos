# Bootstrap

This repository contains the necessary files to build and configure:

- Terraform Cloud Agent
- 2 x HashiCorp Vault Enterprise clusters running in Kubernetes
- 

The objective of this repository is to to create an end-to-end orchestration demo environment that allows for members of the SEA team todemonstrate the capabilities of using HashiCorp Solutions

The demo environment was created with the following principles in mind

- Require no credentials to be stored in Terraform Cloud
- Easily understandable and demonstrable for the intended audience, whether it be for internal stakeholders or external clients.
- Easliy redeployable with a principle of being idempotant
- Low impact on cost for running a demo environment

The entry point into creating this demo enviornment is a bootstrap script (`bootstrap-demo.sh`) located in every subfolder to set up a particular demo.

For example, the first script to run is the `bootstrap-demo.sh` located in the `vault-in-kubernets` to build the base vault clusters. Once this is run, you can utilise other sub directories to build upon that layer with particualr use cases.



# Pre-requisites

## Software

* aws cli
* jq
* [Doormat](https://docs.prod.secops.hashicorp.services/doormat/cli/) - command line tool must be installed and configured with appropriate credentials
* [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)

## Licenses

* A valid Vault license key

## Set required environment variables
Certain unique environment variables are required prior:

# Terraform Cloud Agent Authentication
* echo 'export TFC_AGENT_TOKEN=<>' >> ~/.zshenv


* echo 'export DOORMAT_AWS_USER=<>' >> ~/.zshenv

# Vault Enterprise License Key
* echo 'export VAULT_LICENSE=<>' >> ~/.zshenv

# For Azure authentiation
* echo 'export ARM_CLIENT_ID=<>' >> ~/.zshenv
* echo 'export ARM_CLIENT_SECRET=<>' >> ~/.zshenv
* echo 'export ARM_SUBSCRIPTION_ID=<>' >> ~/.zshenv
* echo 'export ARM_TENANT_ID=<>' >> ~/.zshenv

# Terraform cloud API token

* echo 'export TFE_TOKEN=<>' >> ~/.zshenv

# Usage

```sh { closeTerminalOnSuccess=false }
. ./bootstrap-demo.sh
```


# Clean up
```# Clean up steps
   kubectl delete all --all -n my-vault-demo
   kubectl delete pvc --all
   kubectl delete roles --all
   kubectl get clusterroles | grep '^cert-' | awk '{print $1}' | xargs kubectl delete clusterrole
   kubectl delete clusterroles ingress-nginx vault-dc1-agent-injector-clusterrole vault-dc2-agent-injector-clusterrole
   kubectl get clusterrolebinding | grep '^cert-' | awk '{print $1}' | xargs kubectl delete
   kubectl delete $(kubectl get clusterrolebinding -o=name | grep cert-)
   kubectl delete $(kubectl get clusterrolebinding -o=name | grep vault)

   kubectl get crds -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '\.cert-manager\.io$' | xargs kubectl delete crds 
   kubectl delete namespace my-vault-demo
```

# Notes

* The files are intended for demo purposes only and is not recommended for production use
* The script uses docker kill to stop and remove the Vault container. Be aware that this command will remove any data manually stored in the container.
