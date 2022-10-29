# 1 Real World CI/CD pipeline
## 1.1 Demonstration
Tutorial for build and deploy
```
www.youtube.com/watch?v=kXYiU_JCYtU&list=PLeTAguQ5NROaYkrlKdWa21s9BofsHY5pL&index=57
```

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
Fork and clone your cicd repo
```
git clone https://github.com/dragonflly/cicd.git
cd cicd
```

- Choose your AWS region  
us-east-1
- Replace s3 bucket name for terraform remote state  
terraform-on-eks
- Replace domain name  
ning-cicd.click
- Replace AWS EC2 instance keypair  
cicd/aws/Bastion-Host/private-key  
cicd/aws/tools/private-key  
- Replace Github token  
ghp_H11PU2mTQ9zA0Pv0VNk7h9CRRpEOr71IodtW
- Replace Dockerhub token  
dckr_pat_HIPo8IixCAk1oXA_N7a5HIq2iPI


### 2.2.1 Create S3 bucket and DynamoDB table
```
cd Basic-Services
terraform init
terraform apply -auto-approve
```

### 2.2.2 Create EKS cluster
Create Kubernetes cluster and node group, update kubeconfig.  
It will takes about 15 minutes.
```
cd ../EKS-Cluster
terraform init
terraform apply -auto-approve
aws eks update-kubeconfig --name hr-dev-eksdemo --region us-east-1
```

### 2.2.3 Create LoadBalancer Controller
Create LB Controller with Helm chart
```
cd ../LB-Controller
terraform init
terraform apply -auto-approve
```

### 2.2.4 Create External DNS
Map to AWS Router53, so kubernetes can create records in Route53 host zone
```
cd ../External-DNS
terraform init
terraform apply -auto-approve
```

### 2.2.5 Create Jenkins and sonarqube server
```
cd ../tools
terraform init
terraform apply -auto-approve
```

## 2.3 Config Jenkins
### ssh to jenkins server by bastion host
```
ssh -i eks-terraform-key bastion-host-public-IP  
ssh -i eks-terraform-key jenkins-server-private-IP  
```

### unlock jenkins server from web console
- Get initial password for jenkins admin  
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword  
```

- Jenkins server address  
```
jenkins.ning-cicd.click  
```
- Install suggested plugins  

### clone cicd repo
```
git clone https://github.com/dragonflly/cicd.git  
cd cicd/aws/tools/config-jenkins  
```

### replace jenkins admin token
- Create admin token  
admin -> configure -> API Token -> add new token  
![create admin token](images/cicd-flow.png)
- replace jenkins token in jenkins-CLI.sh  
###  replace github token  
aws/tools/config-jenkins/GITHUB_TOKEN.xml  
aws/tools/config-jenkins/github.xml  
###  replace dockerhub token  
aws/tools/config-jenkins/DockerHub-UP.xml  

### config jenkins by CLI
- download jenkins CLI  
```
wget http://localhost:8080/jnlpJars/jenkins-cli.jar  
```
- replace token, and restart jenkins  
```
java -jar jenkins-cli.jar -auth admin:118befc41e873f41075d9d91df39c33812 -s http://localhost:8080/ safe-restart  
```
- run scripts to config jenkins server  
```
./jenkins-CLI.sh  
```
- Check 3 new created credentials  
![new created credentials](images/cicd-flow.png)

- Check 7 new installed plugins  
Environment Injector  
Git Parameter  
Job DSL  
Active Choices  
build user vars  
AWS steps  
Sonarqube scanner  

## 2.4 Config Sonarqube
```

```

## 2.5 Config ArgoCD
```

```

## 2.6 Launch microserces on EKS cluster
```

```

# 3 CI/CD
## 3.1 Jenkins build
```

```

## 3.2 Jenkins deploy
```

```

## 3.3 ArgoCD deploy
```

```


