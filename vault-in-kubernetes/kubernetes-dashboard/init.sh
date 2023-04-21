#!usr/bin/zsh
kubectl create namespace kubernetes-dashboard
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl -n kubernetes-dashboard create token admin-user
