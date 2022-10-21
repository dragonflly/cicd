#######################################################
# EC2 Instance
#######################################################
# Bastion Host in Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"
  
  name                   = "${var.environment}-BastionHost"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = "t3.micro"
  key_name               = var.instance_keypair
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  tags = local.common_tags
  user_data = file("${path.module}/bash-files/jumpbox-install.sh")
}


#######################################################
# Elastic IP for Bastion Host EC2 instance
#######################################################
# Resource - depends_on Meta-Argument
resource "aws_eip" "bastion_eip" {
  depends_on = [ module.ec2_public, module.vpc ]
  instance = module.ec2_public.id[0]
  vpc      = true
  tags = local.common_tags

  # Local Exec Provisioner (Destroy-Time Provisioner): Triggered during deletion of Resource
  #provisioner "local-exec" {
    #command = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    #working_dir = "bash-files/"
    #when = destroy
    #on_failure = continue
  #}  
}

