# AWS Dynamic Credential using Workload Identity with Custom Hooks (AWS Secrets Engine)

This demo shows how to leverage AWS Secrets Engine with Terraform Cloud workload identity using Custom Hooks via TFC self-managed agents

Vault and self-managed agents are deployed locally, an OIDC trust is established between TFC and Vault, this trust is used to authenticate with Vault via API and custom hooks.

This repos address IP based restrictions on AWS accounts when using doormat credentials by running agents and Vault locally from the same source IP as your doormat request.

For custom agent build see: https://github.com/hashicorp-demo-lab/tfc-agent-custom

![AWS Dynamic Credential using Workload Identity with Custom Hooks](img/AWSCreds.png)

Configure Vault Enterprise for OIDC trust with Terraform Workload Identity and setup AWS secrets engine

```sh { closeTerminalOnSuccess=false }
. ../bootstrap-demo.sh
terraform apply --auto-approve
```

```sh
. ../bootstrap-demo.sh
terraform destroy --auto-approve
```
