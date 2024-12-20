terraform {
  cloud {
    organization = "craigsloggett-lab" # Update the `hcp_terraform_organization_name` variable to match.

    workspaces {
      name    = "hcp-terraform-admin" # Update the `hcp_terraform_owners_workspace_name` variable to match.
      project = "Platform Team"       # Update the `hcp_platform_team_project_name` variable to match.
    }
  }
}
