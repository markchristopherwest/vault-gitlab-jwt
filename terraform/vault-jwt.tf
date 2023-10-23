resource "vault_jwt_auth_backend" "jwt" {
  description  = "Demonstration of the Terraform JWT auth backend"
  path         = "jwt"
  # jwks_url     = "http://host.docker.internal:8080/-/jwks"
  # jwks_ca_pem=@<path_to_pem>
  bound_issuer = "localhost"

  oidc_discovery_url = "https://myco.auth0.com/"
  # bound_issuer       = "https://myco.auth0.com/"
}

resource "vault_jwt_auth_backend_role" "production" {

  backend        = vault_jwt_auth_backend.jwt.path
  role_name      = "myproject-production"
  token_policies = ["myproject-production"]

  # bound_audiences = ["https://myco.test"]
  bound_claims = {
    # namespace_id = ["12", "22", "37"]
    project_id    = "22"
    ref_protected = "true"
    ref_type      = "branch"
    ref           = "auto-deploy-*"
    user_login    = "user_login"
  }
  user_claim = "user_email"
  role_type  = "jwt"
}

resource "vault_jwt_auth_backend_role" "staging" {

  backend        = vault_jwt_auth_backend.jwt.path
  role_name      = "myproject-staging"
  token_policies = ["myproject-staging"]

  # bound_audiences = ["https://myco.test"]
  bound_claims = {
    # namespace_id = ["12", "22", "37"]
    project_id = "22"
    ref_type   = "branch"
    ref        = "master"
    user_login    = "user_login"
  }
  user_claim = "user_email"
  role_type  = "jwt"
}