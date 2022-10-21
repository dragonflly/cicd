#######################################################
# Version
#######################################################
# Terraform Block
terraform {
  required_version = ">= 1.0.0" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }        
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }            
  }
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"  # $HOME/.aws/credentials
}


#######################################################
# Input Variables
#######################################################
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}

# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "hr"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}

# ASG EC2 Instance Type
variable "instance_type" {
  description = "ASG EC2 Instance Type"
  type = string
  default = "t3.medium"
}

# Key Pairs
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "eks-terraform-key"
}

#######################################################
# Local Values
#######################################################
locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
}


#######################################################
# Data Source
#######################################################
# Get latest AMI ID of Amazon Linux2
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]  //owner is ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}