#!usr/bin/zsh
namespace="vault-secrets-operator-system"
#namespace="my-vault-demo"
#namespace="app"
namespace="postgres"
#postgres-postgresql.postgres.svc.cluster.local
#http://vault-dc1-active.my-vault-demo.svc.cluster.local:8200

helm install vault-secrets-operator hashicorp/vault-secrets-operator --namespace="$namespace" --create-namespace --values vault-operator-values.yaml

kubectl get namespaces

helm list -n="$namespace"
k get all -n="$namespace"

k get pods -n="$namespace"
k get deployments -n="$namespace"
k get events -n="$namespace"

k get VaultAuth -n="$namespace"
k describe VaultAuth static-auth -n="$namespace"

k logs vault-secrets-operator-controller-manager-64c8556b8b-hdk8h -n="$namespace"

k describe svc vault-dc1-active -n="$namespace"
 
kubectl create ns app

kubectl apply -f vault-auth-static.yaml
kubectl delete -f vault-auth-static.yaml

kubectl apply -f static-secret.yaml
kubectl delete -f static-secret.yaml

k describe VaultAuth static-auth -n="$namespace"  
k describe VaultStaticSecret vault-kv-app -n="$namespace"
k describe serviceaccount default -n="$namespace"
k describe secret secretkv -n="$namespace"




kubectl get secret secretkv -n="$namespace" -o jsonpath='{.data.role}' | base64 --decode; echo
k get secret -n="$namespace"
k describe secret secretkv -n="$namespace"
kubectl get secret secretkv -n="$namespace" -o jsonpath='{.data.role}' | base64 --decode; echo

kubectl get secret secretkv -o jsonpath='{.data.role}' | base64 --decode; echo






helm upgrade --install postgres bitnami/postgresql --namespace my-vault-demo --set auth.audit.logConnections=true  --set auth.postgresPassword=secret-pass

vault secrets enable -path=demo-pg database

vault write demo-pg/config/demo-pg \
   plugin_name=postgresql-database-plugin \
   allowed_roles="dev-postgres" \
   connection_url="postgresql://{{username}}:{{password}}@postgres-postgresql.postgres.svc.cluster.local:5432/postgres?sslmode=disable" \
   username="postgres" \
   password="secret-pass"


vault write demo-pg/roles/dev-postgres \
   db_name=demo-pg \
   creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
      GRANT ALL PRIVILEGES ON DATABASE postgres TO \"{{name}}\";" \
   backend=demo-pg \
   name=dev-postgres \
   default_ttl="1m" \
   max_ttl="1m"


vault policy write demo-auth-policy-db - <<EOF
path "demo-pg/creds/dev-postgres" {
   capabilities = ["read"]
}
EOF

#vault secrets enable -path=demo-transit transit
vault write -force demo-transit/keys/vso-client-cache

vault policy write demo-auth-policy-operator - <<EOF
path "demo-transit/encrypt/vso-client-cache" {
   capabilities = ["create", "update"]
}
path "demo-transit/decrypt/vso-client-cache" {
   capabilities = ["create", "update"]
}
EOF
