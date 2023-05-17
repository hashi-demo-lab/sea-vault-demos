terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"

}

module "terraform-cloud-agent-kubernetes" {
  source  = "redeux/terraform-cloud-agent/kubernetes"
  version = "1.0.1"

  namespace      = "my-vault-demo"
  agent_name     = var.agent_name
  agent_token    = var.agent_token
  agent_image   = "cloudbrokeraz/tfc-agent-custom"
  agent_version = "2.6"
  cluster_access = true
}