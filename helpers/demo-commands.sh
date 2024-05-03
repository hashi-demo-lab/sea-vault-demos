The commands below are used for demo purposes only
---
Demo KV
---
vault login -method=ldap username=bob

vault read demo-key-value/data/team_pipelines_secrets

vault read demo-key-value/data/aarons-secrets

vault kv get demo-key-value/team_pipelines_secrets

vault kv get -version=2 demo-key-value/team_pipelines_secrets

vault kv get -format=json -mount=demo-key-value  team_pipelines_secrets

vault kv get -field=football_team -mount=demo-key-value  team_pipelines_secrets


---
API Explorer

demo-key-value/data/{path}
---

unset VAULT_TOKEN

----
Database Demo
----

alias mysql="kubectl --namespace=my-vault-demo exec mysql-0 -- mysql"

mysql -u root -p'root' -e "select user from mysql.user;"
mysql -u root -p'root' -e "SHOW DATABASES;"
mysql -u root -p'root' -e "SHOW TABLES FROM my_app;"
mysql -u root -p'root' -e "select first_name from my_app.customers;"

mysql -u root -p'root' -e "SELECT * from my_app.customers;"

unset VAULT_TOKEN
vault login -method=userpass username=bob password=changeme
vault read demo-databases/creds/db-user-readonly
mysql -u root -p'root' -e "select user from mysql.user;"

unset VAULT_TOKEN
vault login -method=userpass username=alice password=changeme
vault read demo-databases/creds/db-user-readwrite
mysql -u root -p'root' -e "select user from mysql.user;"

alias dynamicCreds="mysql -u '' -p''"
dynamicCreds -e "select first_name from my_app.customers;"

---
Vault Secrets Operator Demo
---
kubectl get namespaces
kubectl get deployments -n vault-secrets-operator-system
kubectl get pods -n vault-secrets-operator-system

kubectl apply -f vault-auth-static.yaml
kubectl describe VaultAuth static-auth -n=app

kubectl get secret -n=app
kubectl apply -f static-secret.yaml
kubectl describe VaultStaticSecret vault-kv-app -n=app

k get secret -n=app
k describe secret secretkv -n=app

kubectl describe secret secretkv -n=app
kubectl get secret secretkv -n=app -o jsonpath='{.data.football_team}' | base64 --decode; echo
#Update the football_team in the Vault UI and show the automatic change!
kubectl get secret secretkv -n=app -o jsonpath='{.data.football_team}' | base64 --decode; echo

#kubectl delete -f static-secret.yaml
#kubectl delete -f vault-auth-static.yaml

Explain the the Postgres Database Pod
cd dynamic-secrets
kubectl apply -f .
k get secret -n=demo-ns
k describe secret vso-db-demo -n=demo-ns

kubectl get secret vso-db-demo -n demo-ns -o jsonpath='{.data.username}' | base64 --decode; echo; kubectl get secret vso-db-demo -n demo-ns -o jsonpath='{.data.password}' | base64 --decode; echo

kubectl delete -f .

---
PKI Demo
---
vault write demo-pki-intermediate/issue/my_role common_name=mysupercoolsite.hashibank.com   

k describe certificate demo-hashibank-com-v2

Show it in the UI

---
Encryption as a Service
---
unset VAULT_TOKEN
export VAULT_TOKEN="" 

vault login -method=userpass username=alice password=changeme

vault read demo-databases/creds/db-user-readwrite

alias dynamicCreds="mysql -u '' -p''"

dynamicCreds -e "select birth_date from my_app.customers;"

vault write demo-transit/decrypt/customer-key ciphertext="vault:example"

echo "" | base64 -D; echo


---
LOGS
---
unbuffer kubectl exec -it vault-dc1-0 -- tail -f /vault/audit/audit.txt | jq -r 'select(.type == "request") | "\(.time) \(.request.remote_address) \(.request.operation) \(.request.path) \(.auth.display_name)"'