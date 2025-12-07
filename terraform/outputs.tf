output "api_url" {
  description = "Invoke URL for API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_name" {
  value = aws_lambda_function.crud_lambda.function_name
}

output "dynamodb_table" {
  value = aws_dynamodb_table.items.name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lambda_artifacts.bucket
}



