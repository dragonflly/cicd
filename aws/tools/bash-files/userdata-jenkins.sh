#! /bin/bash
sudo yum update -y
cd ~

# install aws CLI
pip3 uninstall awscli
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# install git
sudo yum install git -y

# Install Docker
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo chkconfig docker on

# //intall javac 11
sudo yum install openjdk-11-jdk-headless
sudo yum install java-11-devel -y

# install maven
sudo wget https://www-eu.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
sudo tar zvxf apache-maven-3.8.6-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.8.6 /opt/maven

# install hub
wget https://github.com/github/hub/releases/download/v2.14.2/hub-linux-amd64-2.14.2.tgz
sudo tar zvxf hub-linux-amd64-2.14.2.tgz
sudo ./hub-linux-amd64-2.14.2/install

#install jenkins
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# add jenkins user
sudo usermod -a -G docker jenkins
newgrp jenkins

