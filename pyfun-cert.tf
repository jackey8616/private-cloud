# ACM-issued, DNS-validated TLS cert for the PyFun API Gateway regional custom
# domain (pyfun-backend-v2.clo5de.info). It lives at root, not in the pyfun module,
# because it spans two providers: the certificate (aws — must be in the API
# Gateway's region, ap-northeast-1) and its DNS validation record (cloudflare — in
# the clo5de.info zone owned by module.DNS). The validated ARN is injected into
# module.PyFun, so the pyfun module stays AWS-only and no private key is ever stored
# — ACM generates and auto-renews it; nothing lands in Secrets Manager or on disk.
resource "aws_acm_certificate" "pyfun_backend_v2" {
  domain_name       = "pyfun-backend-v2.clo5de.info"
  validation_method = "DNS"

  tags = aws_servicecatalogappregistry_application.terraform.application_tag

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "pyfun_backend_v2_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.pyfun_backend_v2.domain_validation_options :
    dvo.domain_name => {
      name    = trimsuffix(dvo.resource_record_name, ".")
      type    = dvo.resource_record_type
      content = trimsuffix(dvo.resource_record_value, ".")
    }
  }

  zone_id = module.DNS.clo5de-info-zone-id
  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  proxied = false
  ttl     = 60
}

resource "aws_acm_certificate_validation" "pyfun_backend_v2" {
  certificate_arn         = aws_acm_certificate.pyfun_backend_v2.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.pyfun_backend_v2_cert_validation : record.name]
}
