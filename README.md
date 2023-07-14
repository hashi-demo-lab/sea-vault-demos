# HashiCorp Vault Demonstrations

This repository contains the necessary files to demonstrate HashiCorp Vault. 
The objective of this repository is to to create an easy deployable environment
that allows for members of the SEA team to demonstrate the capabilities of using 
HashiCorp Vault

![Alt text](image.png)

The repo was created with the following principles in mind

- Require no credentials to be stored in Terraform Cloud
- Easily understandable and demonstrable for the intended audience, 
  whether it be for internal stakeholders or external clients.
- Easliy redeployable and idempotant
- Low impact on cost for running a demo environment

## Get Started
The entry point into this repo is the (`vault-in-kubernetes`) directory.
Within this directory there is a (`bootstrap-demo.sh`) script. 
As the name suggests this will deploy HashiCorp Vault into a Kubernetes environment.
There are pre-reqs required to execute that script. So please read the README.md 
in that directory to get a better understanding of how it works

 Once the base Vault, you can utilise the other directories to build with particular use cases.

## Notes
* The files are intended for demo purposes only and is not recommended for production use