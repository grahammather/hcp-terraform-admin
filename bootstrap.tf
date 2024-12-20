resource "tfe_organization" "this" {
  name  = var.hcp_terraform_organization_name
  email = var.hcp_terraform_organization_email

  lifecycle {
    prevent_destroy = true
  }
}

data "tfe_team" "owners" {
  name         = "owners"
  organization = tfe_organization.this.name
}

data "tfe_organization_membership" "api_org" {
  organization               = tfe_organization.this.name
  organization_membership_id = local.organization_membership_ids.api_org
}

data "tfe_organization_membership" "api_team" {
  organization               = tfe_organization.this.name
  organization_membership_id = local.organization_membership_ids.api_team
}

data "tfe_organization_membership" "gh_webhooks" {
  organization               = tfe_organization.this.name
  organization_membership_id = local.organization_membership_ids.gh_webhooks
}

data "tfe_organization_membership" "doormat" {
  organization               = tfe_organization.this.name
  organization_membership_id = local.organization_membership_ids.doormat
}

data "tfe_organization_membership" "owner" {
  organization = tfe_organization.this.name
  email        = var.hcp_terraform_organization_email
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
    # The human who created the organization.
    data.tfe_organization_membership.owner.id
  ]
}

resource "tfe_project" "default" {
  name         = "Default Project"
  organization = tfe_organization.this.name
  description  = "The default project for new workspaces."
}

# The TFE provider authentication variable set must be created by hand for the first run.

resource "tfe_variable_set" "tfe_provider_authentication" {
  name         = "TFE Provider Authentication"
  description  = "The token used to authenticate the TFE provider for managing this HCP Terraform organization."
  organization = tfe_organization.this.name
}

resource "tfe_workspace_variable_set" "tfe_provider_authentication" {
  workspace_id    = tfe_workspace.hcp_terraform_admin.id
  variable_set_id = tfe_variable_set.tfe_provider_authentication.id
}

# The following project and workspace are created when running `terraform init` for the first time.

resource "tfe_project" "platform_team" {
  name         = var.hcp_platform_team_project_name
  organization = tfe_organization.this.name
  description  = "A collection of workspaces to manage HashiCorp Cloud Platform services."
}

resource "tfe_workspace" "hcp_terraform_admin" {
  name         = var.hcp_terraform_admin_workspace_name
  organization = tfe_organization.this.name
  project_id   = tfe_project.platform_team.id

  terraform_version = var.terraform_version
  queue_all_runs    = false
}
