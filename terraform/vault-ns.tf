
# variable "child_namespaces" {
#   type = set(string)
#   default = [
#     "child_0",
#     "child_1",
#     "child_2",
#   ]
# }

# resource "vault_namespace" "parent" {
#   path = "parent"
# }

# resource "vault_namespace" "children" {
#   for_each  = var.child_namespaces
#   namespace = vault_namespace.parent.path
#   path      = each.key
# }

# resource "vault_mount" "children" {
#   for_each  = vault_namespace.children
#   namespace = each.value.path_fq
#   path      = "secrets"
#   type      = "kv"
#   options = {
#     version = "1"
#   }
# }

# resource "vault_generic_secret" "children" {
#   for_each  = vault_mount.children
#   namespace = each.value.namespace
#   path      = "${each.value.path}/secret"
#   data_json = jsonencode(
#     {
#       "ns" = each.key
#     }
#   )
# }