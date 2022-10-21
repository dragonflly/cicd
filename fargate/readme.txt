
cd EKS-Cluster
terraform init
terraform apply -auto-approve
aws eks --region us-east-1 update-kubeconfig --name hr-dev-eksdemo1

aws eks list-fargate-profiles --cluster=hr-dev-eksdemo1

//coredns pods in pending state
kubectl -n kube-system get pods

# Run the following command to remove the eks.amazonaws.com/compute-type : ec2 annotation from the CoreDNS manifest.
kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
kubectl rollout restart -n kube-system deployment coredns

//Wait for a minute or two, coredns pods in Running state
kubectl -n kube-system get pods


**************************************************
cd ../LB-Controller
terraform init
terraform apply -auto-approve


**************************************************
cd ../External-DNS
terraform init
terraform apply -auto-approve

**************************************************
cd ..
kubectl apply -f tools

**************************************************
