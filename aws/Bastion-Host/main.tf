#############################################################################
# Terraform Settings
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.14"
     }
  }

  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-eks"
    key    = "dev/aws-baston-host/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-bastion-host"    
  }     
}

# Terraform AWS Provider
provider "aws" {
  region = var.aws_region
}


#############################################################################
# Data source
# Remote State Backend
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-on-eks"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = var.aws_region
  }
}


#############################################################################
# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}

# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "hr"
}


#############################################################################
# Local Values
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${data.terraform_remote_state.eks.outputs.cluster_id}"  
}


#############################################################################



