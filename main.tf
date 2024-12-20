# Bootstrap HCP Terraform

resource "tfe_organization" "craigsloggett_lab" {
  name  = var.hcp_terraform_organization_name
  email = var.hcp_terraform_organization_email

  lifecycle {
    prevent_destroy = true
  }
}

data "tfe_team" "owners" {
  name         = "owners"
  organization = tfe_organization.craigsloggett_lab.name
}

# Hidden internal users for HashiCorp's systems.

data "tfe_organization_membership" "api_org" {
  organization               = tfe_organization.craigsloggett_lab.name
  organization_membership_id = "ou-EhS6WkPBDVPxYYqd"
}

data "tfe_organization_membership" "api_team" {
  organization               = tfe_organization.craigsloggett_lab.name
  organization_membership_id = "ou-mLy6EZTkP2bKW9w3"
}

data "tfe_organization_membership" "gh_webhooks" {
  organization               = tfe_organization.craigsloggett_lab.name
  organization_membership_id = "ou-j7QUTL6CcJUktJJC"
}

# Doormat is the service used to manage HCP Terraform organizations for HashiCorp employees.

data "tfe_organization_membership" "doormat" {
  organization               = tfe_organization.craigsloggett_lab.name
  organization_membership_id = "ou-9KRr8gq4h6JikktE"
}

# The user who created the HCP Terraform organization.

data "tfe_organization_membership" "craigsloggett" {
  organization = tfe_organization.craigsloggett_lab.name
  email        = "craig.sloggett@hashicorp.com"
}

resource "tfe_team_organization_members" "owners" {
  team_id = data.tfe_team.owners.id
  organization_membership_ids = [
    # Hidden Users
    data.tfe_organization_membership.api_org.id,
    data.tfe_organization_membership.api_team.id,
    data.tfe_organization_membership.gh_webhooks.id,
    # Doormat User
    data.tfe_organization_membership.doormat.id,
    # Actual Users
    data.tfe_organization_membership.craigsloggett.id
  ]
}

resource "tfe_project" "default" {
  name         = "Default Project"
  organization = tfe_organization.craigsloggett_lab.name
  description  = "The default project for new workspaces."
}

# The TFE provider authentication variable set must be created by hand for the first run.

resource "tfe_variable_set" "tfe_provider_authentication" {
  name         = "TFE Provider Authentication"
  description  = "The token used to authenticate the TFE provider for managing this HCP Terraform organization."
  organization = tfe_organization.craigsloggett_lab.name
}

resource "tfe_workspace_variable_set" "tfe_provider_authentication" {
  workspace_id    = tfe_workspace.hcp_terraform_admin.id
  variable_set_id = tfe_variable_set.tfe_provider_authentication.id
}

# The following project and workspace are created when running `terraform init` for the first time.

resource "tfe_project" "platform_team" {
  name         = var.hcp_platform_team_project_name
  organization = tfe_organization.craigsloggett_lab.name
  description  = "A collection of workspaces to manage HashiCorp Cloud Platform services."
}

resource "tfe_workspace" "hcp_terraform_admin" {
  name         = var.hcp_terraform_admin_workspace_name
  organization = tfe_organization.craigsloggett_lab.name
  project_id   = tfe_project.platform_team.id

  terraform_version = var.terraform_version
  queue_all_runs    = false
}

# Bootstrap has finished, everything below here is a custom addition to an HCP Terraform organization.

resource "tfe_team" "admins" {
  name         = var.hcp_terraform_admins_team_name
  organization = tfe_organization.craigsloggett_lab.name
  visibility   = "secret"

  organization_access {
    access_secret_teams        = true
    manage_agent_pools         = true
    manage_membership          = true
    manage_modules             = true
    manage_organization_access = false
    manage_policies            = true
    manage_policy_overrides    = true
    manage_projects            = true
    manage_providers           = true
    manage_run_tasks           = true
    manage_teams               = true
    manage_vcs_settings        = true
    manage_workspaces          = true
    read_projects              = true
    read_workspaces            = true
  }
}

resource "tfe_team_organization_members" "admins" {
  team_id = tfe_team.admins.id
  organization_membership_ids = [
    data.tfe_organization_membership.craigsloggett.id
  ]
}

resource "tfe_team_project_access" "admins" {
  access     = "admin"
  team_id    = tfe_team.admins.id
  project_id = tfe_project.platform_team.id
}
