########################################
# PROVIDER
########################################
provider "aws" {
  region = var.aws_region
}

########################################
# DYNAMODB TABLE
########################################
resource "aws_dynamodb_table" "items" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

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
        Action = ["dynamodb:*"]
        Resource = [aws_dynamodb_table.items.arn]
      },
      {
        Effect = "Allow"
        Action = ["logs:*"]
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
# LAMBDA FUNCTION
########################################
resource "aws_lambda_function" "crud_lambda" {
  function_name = var.lambda_function_name
  s3_bucket     = var.s3_bucket_name
  s3_key        = "lambda.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn

  # FIXED: ZIP path (works even if workspace has spaces)
  source_code_hash = filebase64sha256(abspath("${path.module}/../lambda.zip"))

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
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

########################################
# API GATEWAY STAGE  (fixed)
########################################
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

########################################
# PERMISSIONS: Allow API Gateway to invoke Lambda
########################################
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}




