#!usr/bin/zsh

for i in 1 2 3
do
    export TFC_AGENT_NAME="tfc-agent$i"
    docker pull --platform amd64 hashicorp/tfc-agent:latest

    # Start Terraform Cloud Agent 
    echo "\n\033[32m---STARTING THE TFC-AGENT CONTAINER---\033[0m"

    if docker inspect "$TFC_AGENT_NAME" &> /dev/null; then
      echo "\033[33mContainer "$TFC_AGENT_NAME" already exists, skipping 'docker run' command.\033[0m"
    else
      docker run -d --rm --platform linux/amd64 --name "$TFC_AGENT_NAME" --network host --cap-add=IPC_LOCK \
        -e "TFC_AGENT_TOKEN=${TFC_AGENT_TOKEN}" \
        -e "TFC_AGENT_NAME=${TFC_AGENT_NAME}" \
        hashicorp/tfc-agent:latest
    fi

    export container_id=$(docker ps -aqf "name=$TFC_AGENT_NAME")
    export local_ip=$(ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
    docker exec -it --user root ${container_id} sh -c "echo '${local_ip} vault-dc1.hashibank.com' >> /etc/hosts"
    docker exec -it --user root ${container_id} sh -c "echo '${local_ip} demo.hashibank.com' >> /etc/hosts"
done