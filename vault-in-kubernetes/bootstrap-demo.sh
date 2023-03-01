#!usr/bin/zsh

# Setup K8s secret for passing licenese file into helm chart
kubectl create secret generic my-vault-license --from-literal=license=${VAULT_LICENSE}

# Define an associative array to store the datacenter names and port numbers
# This allows for a Vault per "datacentre" with a unique port for access via http://localhost:port
declare -A datacentres
datacentres[dc1]=32000
datacentres[dc2]=32001

# Loop through the datacenters
for dc in "${(@k)datacentres}"; do
  # Print the external port for the datacenter
  echo "\n\033[32m---External port for $dc: ${datacentres[$dc]}---\033[0m"

  # Replace the externalPort value in the Helm chart values file
  yq -i '.ui.externalPort = '${datacentres[$dc]}'' ./helm-vault-raft-values.yml

  # Install Vault via Helm chart
  helm install "vault-${dc}" hashicorp/vault --values ./helm-vault-raft-values.yml

  # Wait for the pods to be in a running state
  echo "\n\033[32m---Waiting for pods to be in a running state---\033[0m"
  pod_statuses=()
  while true; do
    # Check the status of each pod
    for i in {0..2}; do
      pod_name="vault-${dc}-$i"
      pod_status=$(kubectl get pod "$pod_name" -o jsonpath='{.status.phase}') &> /dev/null

      # Add the pod status to the array
      pod_statuses+=("$pod_status")
      
      # Print the pod status
      if [[ "$pod_status" != "Running" ]]; then
        echo "Pod $pod_name is not running. Status: $pod_status"
      else
        echo "Pod $pod_name is running"
      fi
    done

    # Check if all pods are in the Running state
    if echo "${pod_statuses[@]}" | grep -qEv "Running"; then
      echo "Not all pods are in the Running state, waiting..."
      sleep 5
    else
      echo "\nAll pods are now in the Running state."
      break
    fi
  done
  sleep 5
  # Initialise Vault  
  echo "\n\033[32m---Configuring Vault for ${dc}---\033[0m"
  vault_operator_pod="vault-${dc}-0"
  init_output=$(kubectl exec "${vault_operator_pod}" -- vault operator init -key-shares=1 -key-threshold=1 -format=json)

  # Store the root token and unseal keys in variables
  export ${dc}_root_token=$(echo "${init_output}" | jq -r ".root_token")
  export ${dc}_unseal_key=$(echo "${init_output}" | jq -r ".unseal_keys_b64[]")

  # Unseal leader
  kubectl exec "${vault_operator_pod}" -- vault operator unseal $(eval echo "\${${dc}_unseal_key}")
 
  # Join each cluster node to the leader
  for i in {1..2}; do
    pod_name="vault-${dc}-$i"
    echo "\n\033[32mJoining pod: ${pod_name} to vault-${dc}\033[0m\n"
    kubectl exec "${pod_name}" -- vault operator raft join "http://vault-${dc}-0.vault-${dc}-internal:8200"
  done

  # Unseal each cluster node
  for i in {1..2}; do
    pod_name="vault-${dc}-$i"
    echo "\n\033[32mUnsealing pod: ${pod_name}\033[0m\n"
    kubectl exec "${pod_name}" -- vault operator unseal $(eval echo "\${${dc}_unseal_key}")
  done
  echo "\033[32mRoot token for ${dc}: $(eval echo "\${${dc}_root_token}")\033[0m"
  echo "\033[32mUnseal key for ${dc}: $(eval echo "\${${dc}_unseal_key}")\033[0m\n"

  # Troubleshooting purposes
  # helm list
  # for i in {0..2} ; do kubectl exec vault-${dc}-$i -- vault status ; done
  # kubectl describe pod vault-${dc}
  # kubectl logs vault-${dc}-0
  # kubectl exec -it vault-${dc}-0 -- /bin/sh
  # vault operator raft list-peers (need to authenticate to vault first)
done