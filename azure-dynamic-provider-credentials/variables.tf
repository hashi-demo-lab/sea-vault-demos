# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "tfc_azure_audience" {
  type        = string
  default     = "api://AzureADTokenExchange"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Azure"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "my-azure-workspace"
  description = "The name of the workspace that you'd like to create and connect to Azure"
}

variable "app_prefix" {
  type        = string
  default     = "my-azure-workspace"
  description = "The name of the workspace that you'd like to create and connect to Azure"
}

### workspace variables

# Organization level variables
variable "organization" {
  description = "TFC Organization to build under"
  type        = string
}

# Workspace level variables
variable "workspace_name" {
  description = "Name of the workspace to create"
  type        = string
}

variable "workspace_description" {
  description = "Description of workspace"
  type        = string
  default     = ""
}

variable "workspace_terraform_version" {
  description = "Version of Terraform to run"
  type        = string
  default     = "latest"
}

variable "workspace_tags" {
  description = "Tags to apply to workspace"
  type        = list(string)
  default     = []
}


## VCS variables (existing VCS connection)
variable "vcs_repo" {
  description = "(Optional) - Map of objects that will be used when attaching a VCS Repo to the Workspace. "
  default     = {}
  type        = map(string)
}

variable "workspace_vcs_directory" {
  description = "Working directory to use in repo"
  type        = string
  default     = "root_directory"
}

# Variables
variable "variables" {
  description = "Map of all variables for workspace"
  type        = map(any)
  default     = {
    "TFC_AZURE_PROVIDER_AUTH": {
      "value": true,
      "description": "Enable Azurre Dynamic Credentials",
      "category": "env",
      "sensitive": false,
      "hcl": false
    }
  }
}

variable "create_project" {
  description = "(Optional) Boolean that allows for the creation of a Project in Terraform Cloud that the workspace will use. This feature is in beta and currently doesn't have a datasource"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "(Optional) Name of the Project that is created in Terraform Cloud if var.create_project is set to true. Note this is currently in beta"
  type        = string
  default     = ""
}

variable "assessments_enabled" {
  description = "(Optional) Boolean that enables heath assessments on the workspace"
  type        = bool
  default     = false
}

# # RBAC
# ## Workspace owner (exising org user)
# variable "workspace_owner_email" {
#   description = "Email for the owner of the account"
#   type        = string
# }

## Additional read users (existing org user)
variable "workspace_read_access_emails" {
  description = "Emails for the read users"
  type        = list(string)
  default     = []
}

## Additional write users (existing org user)
variable "workspace_write_access_emails" {
  description = "Emails for the write users"
  type        = list(string)
  default     = []
}

## Additional plan users (existing org user)
variable "workspace_plan_access_emails" {
  description = "Emails for the plan users"
  type        = list(string)
  default     = []
}




## Kalen Additions

variable "agent_pool_name" {
  type        = string
  description = "(Optional) Name of the agent pool that will be created or used"
  default     = null
}

variable "workspace_agents" {
  type        = bool
  description = "(Optional) Conditional that allows for the use of existing or new agents within a given workspace"
  default     = true
}

variable "workspace_auto_apply" {
  type        = string
  description = "(Optional)  Setting if the workspace should automatically apply changes when a plan succeeds."
  default     = true
}

variable "execution_mode" {
  type        = string
  description = "Defines the execution mode of the Workspace. Defaults to remote"
  default     = "agent"
}

variable "remote_state" {
  type        = bool
  description = "(Optional) Boolean that enables the sharing of remote state between this workspace and other workspaces within the environment"
  default     = false
}

variable "remote_state_consumers" {
  type        = set(string)
  description = "(Optional) Set of remote IDs of the workspaces that will consume the state of this workspace"
  default     = [""]
}