# Configured in the module rather than passed in from root, for the same reason github/ and
# clode-tools/ configure their own: what this module needs from GitHub is one deploy key on one
# repository, and it needs it created before the instance that clones with it (deploy-key.tf).
provider "github" {
  owner = var.github-org-name
  token = var.github-token
}
