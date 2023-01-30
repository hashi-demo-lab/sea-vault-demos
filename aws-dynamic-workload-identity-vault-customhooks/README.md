# AWS Dynamic Credential using Workload Identity with Custom Hooks (AWS Secrets Engine)

![DAWS Dynamic Credential using Workload Identity with Custom Hooks](/img/AWSCreds.png)

Configure Vault Enterprise for OIDC trust with Terraform Workload Identity and setup AWS secrets engine

```sh { closeTerminalOnSuccess=false }
. ../bootstrap-demo.sh
terraform apply --auto-approve
```

```sh
. ../bootstrap-demo.sh
terraform destroy --auto-approve
```
