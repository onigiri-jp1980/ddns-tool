resource "aws_route53_record" "custom_domain_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.api_hostname}.${var.base_domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
