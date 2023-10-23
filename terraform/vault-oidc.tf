resource "vault_jwt_auth_backend" "oidc" {
  description        = "Demonstration of the Terraform JWT auth backend"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://myco.auth0.com/"
  oidc_client_id     = "1234567890"
  oidc_client_secret = "secret123456"
  bound_issuer       = "https://myco.auth0.com/"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "example_oidc" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "test-role"
  token_policies = ["default", "dev", "prod"]

  user_claim            = "https://vault/user"
  role_type             = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
}