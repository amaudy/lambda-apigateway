# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Lambda basic execution policy attachment
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/echo.py"
  output_path = "${path.module}/src/echo.zip"
}

resource "aws_lambda_function" "echo_api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-echo-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "echo.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"

  tags = var.tags
}

# API Gateway
resource "aws_api_gateway_rest_api" "echo_api" {
  name = "${var.project_name}-rest-api"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# API Gateway Resource
resource "aws_api_gateway_resource" "echo_api" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id
  parent_id   = aws_api_gateway_rest_api.echo_api.root_resource_id
  path_part   = "echo"
}

# API Gateway Method
resource "aws_api_gateway_method" "echo_api" {
  rest_api_id   = aws_api_gateway_rest_api.echo_api.id
  resource_id   = aws_api_gateway_resource.echo_api.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

# API Gateway Integration
resource "aws_api_gateway_integration" "echo_api" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id
  resource_id = aws_api_gateway_resource.echo_api.id
  http_method = aws_api_gateway_method.echo_api.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.echo_api.invoke_arn
}

# Enable CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.echo_api.id
  resource_id   = aws_api_gateway_resource.echo_api.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id
  resource_id = aws_api_gateway_resource.echo_api.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id
  resource_id = aws_api_gateway_resource.echo_api.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id
  resource_id = aws_api_gateway_resource.echo_api.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "echo_api" {
  rest_api_id = aws_api_gateway_rest_api.echo_api.id

  depends_on = [
    aws_api_gateway_integration.echo_api,
    aws_api_gateway_integration.options,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "echo_api" {
  deployment_id = aws_api_gateway_deployment.echo_api.id
  rest_api_id   = aws_api_gateway_rest_api.echo_api.id
  stage_name    = var.environment
}

# API Key
resource "aws_api_gateway_api_key" "echo_api" {
  name  = "${var.project_name}-api-key"
  value = var.api_key
}

# Usage Plan
resource "aws_api_gateway_usage_plan" "echo_api" {
  name = "${var.project_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.echo_api.id
    stage  = aws_api_gateway_stage.echo_api.stage_name
  }
}

# Usage Plan Key
resource "aws_api_gateway_usage_plan_key" "echo_api" {
  key_id        = aws_api_gateway_api_key.echo_api.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.echo_api.id
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.echo_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.echo_api.execution_arn}/*/${aws_api_gateway_method.echo_api.http_method}/echo"
}

# Custom Domain Name
resource "aws_api_gateway_domain_name" "echo_api" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn
  security_policy          = "TLS_1_2"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Domain Mapping
resource "aws_api_gateway_base_path_mapping" "echo_api" {
  api_id      = aws_api_gateway_rest_api.echo_api.id
  stage_name  = aws_api_gateway_stage.echo_api.stage_name
  domain_name = aws_api_gateway_domain_name.echo_api.domain_name
}

# Route 53 record
resource "aws_route53_record" "echo_api" {
  name    = aws_api_gateway_domain_name.echo_api.domain_name
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    name                   = aws_api_gateway_domain_name.echo_api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.echo_api.regional_zone_id
    evaluate_target_health = true
  }
} 