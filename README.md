# HashiCorp Vault Demonstrations

This repository contains the necessary files to demonstrate HashiCorp Vault. 
The objective of this repository is to to create an easy deployable environment
that allows for members of the SEA team to demonstrate the capabilities of 
HashiCorp Vault

The repo was created with the following principles in mind

## Get Started
The entry point into this repo is the (`_setup`) directory.
Within this directory there is a (`start-vault.sh`) script. 
As the name suggests this will deploy HashiCorp Vault into a Kubernetes environment.
There are pre-reqs required to execute that script. So please read the README.md 
in that directory to get a better understanding of how it works.

Once the base Vault pods have been deployed, you can utilise the other directories for particular use cases.

## Notes
* The files are intended for demo purposes only and is not recommended for production use.