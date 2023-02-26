#!usr/bin/zsh

# Setup K8s secret for passing licenese file into helm chart
kubectl create secret generic my-vault-license --from-literal=license=${VAULT_LICENSE}\

# Declare the associative array
declare -A datacentres

# Assign the values to the keys
# This allows for a Vault per "datacentre" with a unique port for access via http://localhost:port
datacentres[dc1]=32000
datacentres[dc2]=32001

# Iterate over the keys of the array
for dc in "${(@k)datacentres}"; do
  # Use the key as a variable
  echo "\n\033[32m---External port for $dc: ${datacentres[$dc]}\033[0m"
  # Override the values of the Helm chart. Allowing access to each Vault cluster UI
  yq -i '.ui.externalPort = '${datacentres[$dc]}'' ./helm-vault-raft-values.yml
  # Install Vault via Helm chart
  helm install vault-$dc hashicorp/vault --values ./helm-vault-raft-values.yml

  echo "\n\033[32m---Waiting for pods to be in a running state---\033[0m"
  # create the array of pod names
  POD_NAMES=(vault-${dc}-0 vault-${dc}-1 vault-${dc}-2)

  # Check the status of each pod
  while true; do
    # initialize array to hold pod statuses
    POD_STATUSES=()
    # Loop through the pod names and get the pod status
    for pod_name in "${POD_NAMES[@]}"; do
      # Get the pod status
      pod_status=$(kubectl get pods -l "statefulset.kubernetes.io/pod-name=$pod_name" -o json | jq -r ".items[] | select(.metadata.labels.\"statefulset.kubernetes.io/pod-name\" == \"$pod_name\").status.phase")

      # Check if the pod status is running
      if [[ "$pod_status" != "Running" ]]; then
        echo "Pod $pod_name is not running. Status: $pod_status"
      else
        echo "Pod $pod_name is running"
      fi
    # Add the pod status to the array
    POD_STATUSES+=("$pod_status")
  done

  # Check if all pods are in the Running state
  if echo "${POD_STATUSES[@]}" | grep -qEv "Running"; then
    echo "Not all pods are in the Running state, waiting...\n"
    sleep 5
  else
    echo "All pods are in the Running state.\n"
    break
  fi
done

  # Initialise Vault, join and unseal all cluster nodes 
  echo "\n\033[32m---Configuring Vault for ${dc}---\033[0m"
  kubectl exec "vault-${dc}-0" -- vault operator init -key-shares=1 -key-threshold=1 -format=json > $dc-vault-cluster-keys.json
  kubectl exec "vault-${dc}-0" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${dc}-vault-cluster-keys.json)
  kubectl exec -ti "vault-${dc}-1" -- vault operator raft join "http://vault-$dc-0.vault-${dc}-internal:8200"
  kubectl exec -ti "vault-${dc}-2" -- vault operator raft join "http://vault-$dc-0.vault-${dc}-internal:8200"
  kubectl exec -ti "vault-${dc}-1" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${dc}-vault-cluster-keys.json)
  kubectl exec -ti "vault-${dc}-2" -- vault operator unseal $(jq -r ".unseal_keys_b64[]" ${dc}-vault-cluster-keys.json)

  # Troubleshooting purposes
  # helm list
  # for i in {0..2} ; do kubectl exec vault-${dc}-$i -- vault status ; done
  # vault operator raft list-peers
  # kubectl describe pod vault-${dc}
done