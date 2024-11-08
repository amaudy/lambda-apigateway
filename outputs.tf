output "api_domain_name" {
  description = "Domain name of the API Gateway"
  value       = module.echo_api.api_domain_name
}

output "api_endpoint" {
  description = "Regional domain name of the API Gateway"
  value       = module.echo_api.api_endpoint
}

output "api_stage_url" {
  description = "URL of the API Gateway stage"
  value       = module.echo_api.api_stage_url
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = module.echo_api.function_name
} 