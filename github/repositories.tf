resource "github_repository" "silverfish-backend" {
  name        = "Silverfish-Backend"
  description = "Silverfish backend (Go + go-rod scraping + MongoDB)"
  visibility  = "public"

  has_issues             = true
  has_projects           = true
  delete_branch_on_merge = true
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
}

resource "github_repository" "silverfish-vue" {
  name        = "Silverfish-Vue"
  description = "Silverfish frontend (Vue 3)"
  visibility  = "public"

  has_issues             = true
  has_projects           = true
  delete_branch_on_merge = true
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
}
