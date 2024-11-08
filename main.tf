provider "aws" {
  region = var.aws_region
}

module "echo_api" {
  source = "./modules/echo-api"

  project_name    = var.project_name
  environment     = var.environment
  api_key         = var.api_key
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  route53_zone_id = var.route53_zone_id
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
} 