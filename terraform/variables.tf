variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "ServerlessItemsTable"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "serverless-crud-api"
}

variable "lambda_role_name" {
  description = "IAM role for Lambda"
  type        = string
  default     = "lambda-crud-role"
}

variable "s3_bucket_name" {
  description = "S3 bucket to store Lambda ZIP artifacts"
  type        = string
  default     = "serverless-api-artifacts-pramod"
}



