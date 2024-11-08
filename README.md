# Echo API Service

A simple Echo API service built with AWS API Gateway and Lambda, deployed using Terraform.

## Prerequisites

- AWS CLI configured
- Terraform installed
- A registered domain in Route 53
- A valid SSL certificate in AWS Certificate Manager (in us-east-1 region)

## Setup

1. Clone the repository
2. Create `terraform.tfvars` file based on `terraform.tfvars.example`: 


Make a POST request

```bash
curl -X POST \
    https://api.your-domain.com/echo \
    -H "x-api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello, World!"}'
```