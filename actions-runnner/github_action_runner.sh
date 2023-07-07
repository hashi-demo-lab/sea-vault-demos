#!usr/bin/zsh

export NAMESPACE="my-vault-demo"
https://github.com/hashi-demo-lab
kubectl config set-context --current --namespace="$NAMESPACE"

kubectl create secret generic pre-defined-secret --from-literal=github_token=${GITHUB_TOKEN}

helm install arc --values ./values.yaml \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller



INSTALLATION_NAME="arc-runner-set"
NAMESPACE="my-vault-demo"
GITHUB_CONFIG_URL="https://github.com/<your_enterprise/org/repo>"
GITHUB_PAT="<PAT>"
helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
