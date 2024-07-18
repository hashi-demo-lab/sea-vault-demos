# HashiCorp Vault Cluster Deployed In A Kubernetes Environment

## Summary:

This script automates the setup and configuration of a Vault with AWS Secrets Engine in a Kubernetes environment. It creates the necessary Kubernetes namespaces, sets up secrets using environment variables, and deploys specific services.

## Prerequisites

### CLI Tools Required:
- zsh
- aws
- doormat
- kubectl
- helm
- jq
### Directory & Files:
Ensure there is a /certs directory in the same location as the script. Populate this directory with the required certificate files:
- vault_tls.key
- vault_tls.crt


## Execute
To execute the script using the zsh shell:

``` chmod +x bootstrap-demo.sh
. ./bootstrap-demo.sh
```

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.