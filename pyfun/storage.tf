resource "aws_ecr_repository" "PyFun-Backend" {
  name = "pyfun-backend"

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}
