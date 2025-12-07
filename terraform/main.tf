########################################
# IAM ROLE FOR LAMBDA
########################################

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          aws_dynamodb_table.items.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

########################################
# S3 BUCKET FOR LAMBDA ZIP
########################################

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# LAMBDA FUNCTION (FROM S3 ZIP)
########################################

resource "aws_lambda_function" "crud_lambda" {
  function_name = var.lambda_function_name

  s3_bucket = var.s3_bucket_name
  s3_key    = "lambda.zip"

  # Detect zip file changes (IMPORTANT)
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")

  handler = "index.handler"
  runtime = "nodejs18.x"
  role    = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

########################################
# API GATEWAY (HTTP API)
########################################

resource "aws_apigatewayv2_api" "http_api" {
  name          = "serverless-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.crud_lambda.invoke_arn
  payl



