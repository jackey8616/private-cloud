locals {
  actions-variables = merge([
    for repo, vars in var.repository-variables : {
      for k, v in vars : "${repo}/${k}" => {
        repository    = repo
        variable_name = "TF_${k}"
        value         = v
      }
    }
  ]...)
}

resource "github_actions_variable" "vars" {
  for_each = local.actions-variables

  repository    = each.value.repository
  variable_name = each.value.variable_name
  value         = each.value.value
}
