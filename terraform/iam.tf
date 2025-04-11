# アプリ用Lambdaの実行ロール
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_${var.lambda_function_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 更新用Lambdaの実行ロール
resource "aws_iam_role" "lambda_updater_role" {
  name = "lambda_${var.lambda_updater_function_name}_updater_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Route53操作用カスタムポリシー
resource "aws_iam_role_policy" "lambda_route53_policy" {
  name = "lambda_route53_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })
}



# Lambda操作用ポリシー
resource "aws_iam_role_policy" "lambda_updater_policy" {
  name = "lambda_updater_policy"
  role = aws_iam_role.lambda_updater_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode"
        ],
        Resource = "*"
      }
    ]
  })
}

# 更新用Lambdaの実行ロールにLambda操作用ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_updater_basic_execution" {
  role       = aws_iam_role.lambda_updater_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# アプリ用Lambdaの実行ロールにRoute53操作用ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
