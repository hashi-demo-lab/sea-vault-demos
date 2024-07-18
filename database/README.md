# terraform-template

Deploy a MySQL instance inside docker and then configure Vault Enterprise with the database secrets engine 

```sh { closeTerminalOnSuccess=false }
. ../bootstrap-demo.sh
./bootstrap-usecase.sh
terraform apply --auto-approve
```

```sh
. ../bootstrap-demo.sh
terraform destroy --auto-approve
```


## Cleanup

```
  kubectl delete statefulset transit-app --namespace=my-vault-demo
  kubectl delete service transit-app-svc  --namespace=my-vault-demo
  kubectl delete pvc transit-app-pvc --namespace=my-vault-demo

  kubectl delete statefulset mysql --namespace=my-vault-demo
  kubectl delete service mysql  --namespace=my-vault-demo
  kubectl delete pvc mysql-pvc  --namespace=my-vault-demo
```