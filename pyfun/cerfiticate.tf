resource "aws_acm_certificate" "pyfun-backend-v2_clo5de_info" {
  private_key      = file(var.Cert_Key_Path)
  certificate_body = file(var.Cert_Pem_Path)

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}
