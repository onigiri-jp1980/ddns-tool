resource "aws_cloudwatch_event_rule" "ecr_push_rule" {
  name        = "ecr-push-to-updater-lambda"
  description = "Trigger Lambda when an image is pushed to ECR with specific tag"

  event_pattern = jsonencode({
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {
      "action-type": ["PUSH"],
      "repository-name": [var.ecr_repository_name],
      "image-tag": ["latest"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_updater_lambda" {
  rule      = aws_cloudwatch_event_rule.ecr_push_rule.name
  target_id = "InvokeUpdaterLambda"
  arn       = aws_lambda_function.updater_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updater_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_rule.arn
}
