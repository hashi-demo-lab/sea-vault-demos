#!usr/bin/zsh

# Unset out current status of the Environment Variables

# Setup K8s secret for passing licenese file into helm chart
kubectl create secret generic my-vault-license --from-literal=license=${VAULT_LICENSE}\

# Declare the associative array
declare -A externalPorts

# Assign the values to the keys
# This allows for a Vault per "DC" with a unique port for access via http://localhost:port
externalPorts[dc1]=32000
externalPorts[dc2]=32001

# Iterate over the keys of the array
for element in "${(@k)externalPorts}"; do
  # Use the key as a variable
  echo "External port for $element: ${externalPorts[$element]}"
  # Updating the helm values to change the external port to connect to the Vault UI for each Vault cluster
  yq -i '.ui.externalPort = '${externalPorts[$element]}'' ./helm-vault-raft-values.yml
  # Install Vault via Helm chart
  helm install vault-$element hashicorp/vault --values ./helm-vault-raft-values.yml

  # Sleep required to make sure all pods are running
  sleep 15
  # Initalise Vault, join and unseal all nodes
  kubectl exec "vault-${element}-0" -- vault operator init -key-shares=1 -key-threshold=1 -format=json > $element-vault-cluster-keys.json
  kubectl exec "vault-${element}-0" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${element}-vault-cluster-keys.json)
  kubectl exec -ti "vault-${element}-1" -- vault operator raft join "http://vault-$element-0.vault-${element}-internal:8200"
  kubectl exec -ti "vault-${element}-2" -- vault operator raft join "http://vault-$element-0.vault-${element}-internal:8200"
  kubectl exec -ti "vault-${element}-1" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${element}-vault-cluster-keys.json)
  kubectl exec -ti "vault-${element}-2" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${element}-vault-cluster-keys.json)

  #troubleshooting purposes
  kubectl exec -it "vault-${element}-0" -- vault status
  kubectl exec -it "vault-${element}-1" -- vault status
  kubectl exec -it "vault-${element}-2" -- vault status
done