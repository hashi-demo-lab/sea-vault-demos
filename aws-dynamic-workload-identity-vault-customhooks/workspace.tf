module "workspace" {
  source = "github.com/hashicorp-demo-lab/terraform-tfe-onboarding-module"

  organization = var.organization

  create_project = var.create_project
  project_name   = var.project_name

  workspace_name        = var.workspace_name
  workspace_description = var.workspace_description

  workspace_terraform_version = var.workspace_terraform_version
  workspace_tags              = var.workspace_tags
  variables                   = var.variables

  remote_state           = var.remote_state
  remote_state_consumers = var.remote_state_consumers

  vcs_repo                = var.vcs_repo
  workspace_vcs_directory = var.workspace_vcs_directory
  workspace_auto_apply    = var.workspace_auto_apply


  workspace_agents = var.workspace_agents
  execution_mode   = var.execution_mode
  agent_pool_name  = var.agent_pool_name

  assessments_enabled = var.assessments_enabled

  workspace_read_access_emails  = var.workspace_read_access_emails
  workspace_write_access_emails = var.workspace_write_access_emails
  workspace_plan_access_emails  = var.workspace_plan_access_emails

}



