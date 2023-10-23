resource "vault_mount" "kvv1" {
  path        = "kvv1"
  type        = "kv"
  options     = { version = "1" }
  description = "KV Version 1 secret engine mount"
}

resource "vault_kv_secret" "function" {
  for_each = toset(["default", "dev", "prod"])
  path     = "${vault_mount.kvv1.path}/secret/${each.key}/db"
  data_json = jsonencode(
    {
      password = "${each.key}"
    }
  )
}

