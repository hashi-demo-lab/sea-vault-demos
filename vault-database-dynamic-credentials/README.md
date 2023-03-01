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
