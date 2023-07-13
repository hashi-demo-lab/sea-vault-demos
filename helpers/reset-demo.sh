#!usr/bin/zsh
#AUTHOR: AARON E
#THIS SCRIPT IS QUICK RESET OF A LOCAL DEMO ENVIRONMENT
#MAINLY USED FOR WHEN DEMO'ING VAULT-IN-KUBERNETES, 
#KEY/VALUE SECRET ENGINE AND AWS DYNAMIC CREDS SECRET ENGINE

rm ../vault-kv-secrets-engine/*.tfstate*
cd ../vault-in-kubernetes
. ./cleanup-demo.sh  
sleep 2

. ./bootstrap-demo.sh
sleep 2

cd ../vault-kv-secrets-engine
terraform apply -auto-approve
sleep 2

cd ../vault-aws-dynamic-credentials
terraform apply -auto-approve

clear
for dc in dc1 dc2; do
  echo "\033[32mRoot token for $dc: $(eval echo "\${${dc}_root_token}")\033[0m"
  echo "\033[32mUnseal key for $dc: $(eval echo "\${${dc}_unseal_key}")\033[0m\n"
done