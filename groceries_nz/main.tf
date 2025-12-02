resource "aws_servicecatalogappregistry_application" "groceries_nz" {
  name = "groceries_nz"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
