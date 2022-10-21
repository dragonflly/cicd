# Terraform Settings
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.14"
     }
  }
}

# Terraform Provider
provider "aws" {
  region = "us-east-1"
}
