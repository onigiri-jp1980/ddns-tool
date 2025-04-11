resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.api_hostname}.${var.base_domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "APIGatewayCertificate"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

data "aws_route53_zone" "selected" {
  name         = "${var.base_domain_name}."  # ←ドメイン名（末尾にドット必要！）
  private_zone = false
}