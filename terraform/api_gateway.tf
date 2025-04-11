resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  target = aws_lambda_function.app_function.invoke_arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_domain_name" "custom_domain" {
  domain_name = "${var.api_hostname}.${var.base_domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}