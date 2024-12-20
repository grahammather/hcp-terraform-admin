locals {
  organization_membership_ids = {
    # Hidden internal users for HashiCorp's systems.
    api_org     = "ou-EhS6WkPBDVPxYYqd"
    api_team    = "ou-mLy6EZTkP2bKW9w3"
    gh_webhooks = "ou-j7QUTL6CcJUktJJC"
    # Doormat is the service used to manage HCP Terraform organizations for HashiCorp employees.
    doormat = "ou-9KRr8gq4h6JikktE"
  }
}
