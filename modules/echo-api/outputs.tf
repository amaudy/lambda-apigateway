output "api_domain_name" {
  description = "Domain name of the API Gateway"
  value       = aws_api_gateway_domain_name.echo_api.domain_name
}

output "api_endpoint" {
  description = "Regional domain name of the API Gateway"
  value       = aws_api_gateway_domain_name.echo_api.regional_domain_name
}

output "api_stage_url" {
  description = "URL of the API Gateway stage"
  value       = "https://${aws_api_gateway_domain_name.echo_api.domain_name}/echo"
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.echo_api.function_name
}

output "api_key" {
  description = "The API Key"
  value       = aws_api_gateway_api_key.echo_api.value
  sensitive   = true
} 