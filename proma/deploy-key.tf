# How the box gets the code. The application repository is private, so something on the instance
# has to authenticate to GitHub — and a read-only deploy key is the smallest thing that can: it
# reaches exactly one repository, it cannot push, and rotating it is an apply rather than an
# errand in a web console.
#
# **Both halves are declared here, and that is an ordering decision rather than a filing one.**
# The natural home for anything touching GitHub is the github/ module, but the key has to exist
# on GitHub *before* this instance boots, because cloud-init clones during first boot — and a
# module that received the public half from here would necessarily run after it. Registering it
# beside the instance is what lets `depends_on` say so (instance.tf).
#
# The repository itself is deliberately not a `github_repository` resource: it exists already,
# and adopting it would be an import rather than a create. A deploy key needs only the name.
resource "tls_private_key" "github-deploy" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "proma" {
  repository = element(split("/", var.github-repo), 1)
  title      = "private-cloud: proma instance (read-only)"
  key        = trimspace(tls_private_key.github-deploy.public_key_openssh)
  read_only  = true
}
