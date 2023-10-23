#!/bin/bash
set -e


export GITLAB_HOME="/usr/local/gitlab"

mkdir -p /usr/local/gitlab


echo "Spawning Gitlab via Docker"
if [ ! "$(docker ps -q -f name=gitlab)" ]; then
    echo "Cleaning Up gitlab"
    docker stop gitlab
    docker rm gitlab
    if [ "$(docker ps -aq -f status=exited -f name=gitlab)" ]; then
        echo "Cleaning Up gitlab"
        docker rm gitlab
    fi
    echo "Running Docker gitlab"

    docker run --detach \
    --hostname localhost \
    --publish 8443:443 --publish 8080:80 --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume $GITLAB_HOME/config:/etc/gitlab \
    --volume $GITLAB_HOME/logs:/var/log/gitlab \
    --volume $GITLAB_HOME/data:/var/opt/gitlab \
    --shm-size 256m \
    gitlab/gitlab-ee:latest
    
fi



# you'll need to tell OSX security that you trust gitlab plugin binary
pkill vault
bash -c "vault server -dev -dev-root-token-id=root  > /dev/null &"

echo "sleepy time"
sleep 10
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_ROOT_TOKEN="root"

cd terraform
terraform init
terraform apply -auto-approve


cd ..

echo "Username: root"
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
open http://localhost:8080

