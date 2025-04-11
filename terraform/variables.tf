variable "lambda_function_name" {
  description = "The name of Lambda function"
  type        = string
}
variable "base_domain_name" {
  description = "The name of Lambda function"
  type        = string
}
variable "api_hostname" {
  description = "The name of the ECR repository to store the Lambda images."
  type        = string
}
variable "ecr_repository_name" {
  description = "The name of the ECR repository to store the Lambda images."
  type        = string
}
variable "lambda_updater_function_name" {
  description = "The name of the updater Lambda function."
  type        = string
}
variable "api_gateway_name" {
  description = "The name of the API Gateway."
  type        = string
}
