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

resource "github_repository" "knight-strike" {
  name        = "knight-strike"
  description = ""
  visibility  = "public"

  has_issues             = true
  has_projects           = true
  delete_branch_on_merge = true
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
}

# GitHub Pages custom domain. The Pages site is built by a workflow; this only
# sets the custom domain (Settings → Pages → Custom domain). The cname is sourced
# from the dns/ module's knight-strike CNAME (var) so the two can't drift.
resource "github_repository_pages" "knight-strike" {
  repository = github_repository.knight-strike.name
  build_type = "workflow"
  cname      = var.knight-strike-pages-cname
}
