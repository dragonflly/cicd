#######################################################
# Create a Null Resource and Provisioners
#######################################################
resource "null_resource" "name" {
  depends_on = [module.ec2_public]

  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip    
    user     = "ec2-user"
    password = ""
    private_key = file("private-key/eks-terraform-key.pem")
  }  

  ## File Provisioner: Copies the eks-terraform-key.pem file to /tmp/eks-terraform-key.pem
  provisioner "file" {
    source      = "private-key/eks-terraform-key.pem"
    destination = "/home/ec2-user/eks-terraform-key.pem"
  }

  ## Remote Exec Provisioner: fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/ec2-user/eks-terraform-key.pem"
    ]
  }

  ## Local Exec Provisioner: (Creation-Time Provisioner - Triggered during Create Resource)
  #provisioner "local-exec" {
    #command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    #working_dir = "bash-files/"
    #on_failure = continue
  #}

}

