resource "vault_policy" "example" {
  for_each = toset(["default", "dev", "prod"])
  name     = "${each.key}-team"

  policy = <<EOT
path "secret/${each.key}" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "gitlab" {
  for_each = toset(["production", "staging"])
  name     = "myproject-${each.key}"

  policy = <<EOT
path "secret/data/{{identity.entity.aliases.ACCESSOR_NAME.metadata.project_path}}/${each.key}/*" {
  capabilities = ["read"]
}
EOT
}