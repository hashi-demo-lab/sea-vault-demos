#!usr/bin/zsh

rm ../vault-kv-secrets-engine/*.tfstate*
cd ../vault-in-kubernetes
. ./cleanup-demo.sh  
sleep 2

. ./bootstrap-demo.sh
sleep 2

cd ../vault-kv-secrets-engine
terraform apply -auto-approve
sleep 2

cd ../aws-dynamic-workload-identity-vault-customhooks
terraform apply -auto-approve

clear
for dc in dc1 dc2; do
  echo "\033[32mRoot token for $dc: $(eval echo "\${${dc}_root_token}")\033[0m"
  echo "\033[32mUnseal key for $dc: $(eval echo "\${${dc}_unseal_key}")\033[0m\n"
done