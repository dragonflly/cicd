### install pre requires for argocd applications

### connect github repo using https
kubectl apply -f base/git-connect.yaml

### create namespaces for all environments
kubectl apply -f base/namespaces.yaml

### create projects for all argocd applications
kubectl apply -f base/projects.yaml

### create applications
kubectl apply -f env-dev/microservice-1-dev.yaml

kubectl apply -f env-stage/microservice-1-stage.yaml

kubectl apply -f env-prod/microservice-1-prod.yaml
