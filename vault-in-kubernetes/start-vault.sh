#!usr/bin/zsh
# Define variables and set Kubernetes context
namespace="my-vault-demo"
datacentres=("dc1" "dc2")
kubectl get namespace "$namespace" >/dev/null 2>&1 || kubectl create namespace "$namespace"
kubectl config set-context --current --namespace="$namespace"

# Setup K8s secret for passing into helm chart
kubectl create secret generic vault-secrets \
    --from-literal=license="${VAULT_LICENSE}" \
    --from-file=tls.key=./cert/vault_tls.key \
    --from-file=tls.crt=./cert/vault_tls.crt \
    --from-literal=AWS_ACCESS_KEY_ID="" \
    --from-literal=AWS_SECRET_ACCESS_KEY="" \
    --from-literal=AWS_SESSION_TOKEN=""

# Deploy ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
--set controller.extraArgs.enable-ssl-passthrough=""
sleep 30

# Loop through the datacenters
for dc in "${datacentres[@]}"; do
  # Print the external port for the datacenter
  echo "\n\033[32m---Datacenter: $dc---\033[0m"

  # Add hashicorp heml repo
  helm repo add hashicorp https://helm.releases.hashicorp.com

  # Install Vault via Helm chart
  helm install "vault-${dc}" hashicorp/vault --values ./helm-vault-raft-values.yml \
  --set "server.ingress.hosts[0].host=vault-$dc.hashibank.com" \
  --set "server.ingress.tls[0].hosts[0]=vault-$dc.hashibank.com" \
  --namespace my-vault-demo --create-namespace

  # Wait for the pods to be in a running state
  echo "\n\033[32m---Waiting for pods to be in a running state---\033[0m"
  pod_statuses=()
  while true; do
    # Check the status of each pod
    for i in {0..2}; do
      pod_name="vault-${dc}-$i"
      pod_status=$(kubectl --namespace="$namespace" get pod "$pod_name" -o jsonpath='{.status.phase}') &> /dev/null

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
      echo "\n\033[32m---All pods are now in the Running state---\033[0m"
      break
    fi
  done
  sleep 5
  # Initialise Vault  
  echo "\n\033[32m---Configuring Vault for ${dc}---\033[0m"
  vault_operator_pod="vault-${dc}-0"
  init_output=$(kubectl --namespace="$namespace" exec "${vault_operator_pod}" -- vault operator init -key-shares=1 -key-threshold=1 -format=json)

  # Store the root token and unseal keys in variables
  export ${dc}_root_token=$(echo "${init_output}" | jq -r ".root_token")
  export ${dc}_unseal_key=$(echo "${init_output}" | jq -r ".unseal_keys_b64[]")

  # Unseal leader
  kubectl --namespace="$namespace" exec "${vault_operator_pod}" -- vault operator unseal $(eval echo "\${${dc}_unseal_key}")
 
  # Join each cluster node to the leader
  for i in {1..2}; do
    pod_name="vault-${dc}-$i"
    echo "\n\033[32mJoining pod: ${pod_name} to vault-${dc}\033[0m\n"
    kubectl --namespace="$namespace" exec "${pod_name}" -- vault operator raft join "http://vault-${dc}-0.vault-${dc}-internal:8200"
  done

  # Unseal each cluster node
  for i in {1..2}; do
    pod_name="vault-${dc}-$i"
    echo "\n\033[32mUnsealing pod: ${pod_name}\033[0m\n"
    kubectl --namespace="$namespace" exec "${pod_name}" -- vault operator unseal $(eval echo "\${${dc}_unseal_key}")
  done
  echo "\033[32mRoot token for ${dc}: $(eval echo "\${${dc}_root_token}")\033[0m"
  echo "\033[32mUnseal key for ${dc}: $(eval echo "\${${dc}_unseal_key}")\033[0m\n"
done

# Setup base details for access
export VAULT_TOKEN=$dc1_root_token
export VAULT_PORT=443
export VAULT_ADDR=https://vault-dc1.hashibank.com:${VAULT_PORT}
output_file="vault_keys.json"

# Initialize an empty JSON object
echo "{}" > "$output_file"

for dc in dc1 dc2; do
  root_token=$(eval echo "\${${dc}_root_token}")
  unseal_key=$(eval echo "\${${dc}_unseal_key}")

  # Use jq to add the data center's tokens and keys to the JSON object
  jq --arg dc "$dc" \
     --arg root_token "$root_token" \
     --arg unseal_key "$unseal_key" \
     '.[$dc] = {"root_token": $root_token, "unseal_key": $unseal_key}' \
     "$output_file" > tmp.json && mv tmp.json "$output_file"
done