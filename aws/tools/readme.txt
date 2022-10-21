### Create ALB and ASG, install jenkins and sonarqube
terraform init
terraform apply -auto-approve

### Config jenkins
follow config-jenkins/readme.txt

### Config sonarqube
From Sonarqube server
- http://jenkins.ning-cicd.click:9000/
  Initial username and password: admin & admin
- Generate a sonarqube token to authenticate from Jenkins
  add project -> manually -> project name & dispaly name -> enter token name -> continue -> Maven

From Jenkins server
- https://jenkins.ning-cicd.click
- Configure Sonarqube credentials (secret text from previous step)
- Add Sonarqube Server to jenkins
  Configure System -> SonarQube servers -> check Environment variables -> Add Sonarqube
  name: sonaqube-server (match with codes in pipeline_build.grooy)
  http://jenkins.ning-cicd.click:9000/
  Select sonarqube credential
- Install SonarScanner
  Global Tool Configuration -> SonarQube Scanner -> Add SonarQube Scanner -> install automatically

### Config argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# argocd url
kubectl get service -n argocd
# default password for admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

