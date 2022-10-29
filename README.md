# 1 Real World CI/CD pipeline
## 1.1 Demonstration

## 1.2 Work flow
![cicd flow](images/cicd-flow.png)

## 1.3 Components
Jenkins job, Jenkins build pipeline, Jenkins deploy pipeline  
AWS Kubernetes Cluster (EKS), Ingress, HPA, Helm template, External DNS  
AWS DynamoDB, Route53, ALB, ASG, S3 bucket  
ArgoCD  
Github repo  
Dockerhub repo  
Sonarqube  

## 1.4 Languages
Terraform, YAML, Groovy, bash  

## 1.5 Related repos
https://github.com/dragonflly/jenkinsPipeline.git  
https://github.com/dragonflly/ms-1.git  
https://github.com/dragonflly/ms-2.git  
https://github.com/dragonflly/ms-3.git  

# 2 Installation Instructions
## 2.1 Prerequisites
AWS account  
Github account  
Dockerhub account  

## 2.2 Create AWS resource with Terraform
Clone cicd repo
```
git clone https://github.com/dragonflly/cicd.git
cd cicd
```

### 2.2.1 Create S3 bucket and DynamoDB table
Choose your AWS region and s3 bucket name, then
```
cd Basic-Services
terraform init
terraform apply -auto-approve
cd ..
```

### 2.2.2 Create EKS cluster

### 2.2.3 Create LoadBalancer Controller

### 2.2.4 Create External DNS

### 2.2.5 Create Jenkins and sonarqube server


## 2.3 Config Jenkins

## 2.4 Config Sonarqube

## 2.5 Launch microserces on EKS cluster

## 2.6 Jenkins build

## 2.7 Jenkins deploy



