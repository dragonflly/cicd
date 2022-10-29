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
- Choose your AWS region
us-east-1
- Replace s3 bucket name for remote state
terraform-on-eks
- Replace domain name
ning-cicd.click
- Replace keypair
cicd/aws/Bastion-Host/private-key
cicd/aws/tools/private-key
- Replace Github token
ghp_H11PU2mTQ9zA0Pv0VNk7h9CRRpEOr71IodtW
- Replace Dockerhub token
dckr_pat_HIPo8IixCAk1oXA_N7a5HIq2iPI

Then
```
cd Basic-Services
terraform init
terraform apply -auto-approve
cd ..
```

### 2.2.2 Create EKS cluster
Create Kubernetes cluster and node group, update kubecofing. 
It will takes about 15 minutes.
```
cd EKS-Cluster
terraform init
terraform apply -auto-approve
aws eks update-kubeconfig --name hr-dev-eksdemo --region us-east-1
cd ..
```

### 2.2.3 Create LoadBalancer Controller
Create LB Controller with Helm chart
```
cd LB-Controller
terraform init
terraform apply -auto-approve
cd ..
```

### 2.2.4 Create External DNS
Map to AWS Router53, so kubernetes can create records in Route53 host zone
```
cd External-DNS
terraform init
terraform apply -auto-approve
cd ..
```

### 2.2.5 Create Jenkins and sonarqube server
```

```


## 2.3 Config Jenkins
```

```

## 2.4 Config Sonarqube
```

```

## 2.5 Launch microserces on EKS cluster
```

```

## 2.6 Jenkins build
```

```

## 2.7 Jenkins deploy
```

```



