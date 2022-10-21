#######################################################
# Security Group module
#######################################################
# SG for Baston Host
module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name = "public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
}

# SG for jenkins EC2 Instances
module "jenkins_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"
  
  name = "jenkins-sg"
  description = "Security Group with HTTP & SSH port open"
  vpc_id = module.vpc.vpc_id
  
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["ssh-tcp", "http-80-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
}

module "sonarqube_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "sonarqube_sg"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "sonarqube ports"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_rules        = ["all-all"]
}

# SG for ALB
module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name = "loadbalancer-sg"
  description = "Security Group with HTTP open for entire Internet (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  
  # Ingress Rules & CIDR Blocks
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "Allow Port 9000 from internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = local.common_tags
}

# SG for RDS
module "rdsdb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "rdsdb-sg"
  description = "Access to MySQL DB for entire VPC CIDR Block"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
  
  # Egress Rule - all-all open
  egress_rules = ["all-all"]  
  tags = local.common_tags  
}
