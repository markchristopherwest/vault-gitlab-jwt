# vault-gitlab-jwt

Following the instructions provided by GitLab for Vault integration here:


export GITLAB_HOME="/usr/local/gitlab"

sudo mkdir -p /usr/local/gitlab


echo "Spawning Gitlab via Docker"
if [ ! "$(docker ps -q -f name=gitlab)" ]; then
    # echo "Cleaning Up gitlab"
    # docker stop gitlab
    # docker rm gitlab
    if [ "$(docker ps -aq -f status=exited -f name=gitlab)" ]; then
        echo "Cleaning Up gitlab"
        docker rm gitlab
    fi
    echo "Running Docker gitlab"

    sudo docker run --detach \
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



sudo docker run --detach \
  --hostname localhost \
  --publish 8443:443 --publish 8080:80 --publish 2222:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ee:latest

# you'll need to tell OSX security that you trust gitlab plugin binary
pkill vault
bash -c "vault server -dev -dev-root-token-id=root  > /dev/null &"

echo "sleepy time"
sleep 10
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_ROOT_TOKEN="root"
vault login root

# https://docs.gitlab.com/ee/ci/examples/authenticating-with-hashicorp-vault/#example

vault secrets enable -version=2 kv


# https://learn.hashicorp.com/tutorials/vault/getting-started-first-secret#write-a-secret

vault kv put -mount=secret secret/myproject/staging/db password=foo
vault kv put -mount=secret secret/myproject/production/db password=bar


# https://www.vaultproject.io/docs/auth/jwt
vault auth enable jwt

# Then create policies that allow you to read these secrets (one for each secret):

vault policy write myproject-staging - <<EOF
# Policy name: myproject-staging
#
# Read-only permission on 'secret/myproject/staging/*' path
path "secret/myproject/staging/*" {
  capabilities = [ "read" ]
}
EOF

# Then create policies that allow you to read these secrets (one for each secret):

vault policy write myproject-production - <<EOF
# Policy name: myproject-production
#
# Read-only permission on 'secret/myproject/production/*' path
path "secret/myproject/production/*" {
  capabilities = [ "read" ]
}
EOF

# You also need roles that link the JWT with these policies.

# One for staging named myproject-staging:

vault write auth/jwt/role/myproject-staging - <<EOF
{
  "role_type": "jwt",
  "policies": ["myproject-staging"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims": {
    "project_id": "22",
    "ref": "master",
    "ref_type": "branch"
  }
}
EOF

# And one for production named myproject-production:

vault write auth/jwt/role/myproject-production - <<EOF
{
  "role_type": "jwt",
  "policies": ["myproject-production"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "project_id": "22",
    "ref_protected": "true",
    "ref_type": "branch",
    "ref": "auto-deploy-*"
  }
}
EOF

# The claim fields listed in the table above can also be accessed for Vault’s policy path templating purposes by using the accessor name of the JWT auth within Vault. The mount accessor name (ACCESSOR_NAME in the example below) can be retrieved by running vault auth list.



# Policy template example making use of a named metadata field named project_path:


vault policy write myproject-production - <<EOF
# Policy name: myproject-production
#
# Read-only permission on 'secret/myproject/production/*' path
path "secret/data/{{identity.entity.aliases.ACCESSOR_NAME.metadata.project_path}}/staging/*" {
  capabilities = [ "read" ]
}
EOF

