variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "api_key" {
  description = "API Key for the Gateway"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for the API Gateway custom domain"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
} 