#アプリ用Lambda
resource "aws_lambda_function" "app_function" {
  function_name = var.lambda_function_name

  package_type = "Image"
  #image_uri    = "194817572589.dkr.ecr.ap-northeast-1.amazonaws.com/ddns-tool/app:latest"
  image_uri    = "${aws_ecr_repository.app_repository.repository_url}:latest"

  role = aws_iam_role.lambda_exec_role.arn

  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      ENV = "production"
    }
  }

  tags = {
    Name = "AppLambdaFunction"
  }
}


#更新用Lambda
resource "aws_lambda_function" "updater_function" {
  function_name = var.lambda_updater_function_name

  filename         = data.archive_file.lambda_updater.output_path
  source_code_hash = data.archive_file.lambda_updater.output_base64sha256
  handler          = "main.lambda_handler"
  runtime          = "python3.12"

  role = aws_iam_role.lambda_updater_role.arn

  environment {
    variables = {
      FUNCTION_NAME = var.lambda_function_name
      IMAGE_URI     = "${aws_ecr_repository.app_repository.repository_url}:latest"
    }
  }

  timeout = 30
  memory_size = 256

  tags = {
    Name = "UpdaterLambdaFunction"
  }
}

data "archive_file" "lambda_updater" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_updater"
  output_path = "${path.module}/lambda_updater.zip"
}
