output "api_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api.function_name
}

output "dynamodb_table" {
  description = "DynamoDB Table Name"
  value       = aws_dynamodb_table.table.name
}

output "s3_bucket" {
  description = "S3 bucket for Lambda artifacts"
  value       = aws_s3_bucket.lambda_artifacts.id
}

