output "lambda_bucket_name" {
  value = aws_s3_bucket.lambda_artifacts.bucket
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}




