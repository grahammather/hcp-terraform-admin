# When migrating this code base to a new organization, these IDs will need to be updated.

import {
  id = "craigsloggett-lab" # Organizations can only be imported by name.
  to = tfe_organization.craigsloggett_lab
}

import {
  id = "team-p9ryLNrpQ9TNmEFh"
  to = tfe_team_organization_members.owners
}

import {
  id = "prj-1ifijXyay7xeH9Zc"
  to = tfe_project.default
}

import {
  id = "prj-qW7NitPW1R49WN4b"
  to = tfe_project.platform_team
}

import {
  id = "varset-FwFGK65suTr7eaAA"
  to = tfe_variable_set.tfe_provider_authentication
}

import {
  id = "craigsloggett-lab/hcp-terraform-admin/TFE Provider Authentication"
  to = tfe_workspace_variable_set.tfe_provider_authentication
}

import {
  id = "ws-aAUcuGF6QEJKuQyL"
  to = tfe_workspace.hcp_terraform_admin
}
