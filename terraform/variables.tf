variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "lambda_s3_key" {
  description = "S3 key for Lambda zip file"
  type        = string
  default     = "lambda/latest.zip"
}

variable "lambda_runtime" {
  description = "Lambda runtime to use"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_handler" {
  description = "Lambda handler function"
  type        = string
  default     = "index.handler"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "serverless-crud-table"
}

