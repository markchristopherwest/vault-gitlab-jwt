
# data "gitlab_projects" "group_projects" {
#   group_id          = data.gitlab_group.mygroup.id
#   order_by          = "name"
#   include_subgroups = true
#   with_shared       = false
# }

# locals {

#     list_of_project_ids = []

# }


# # Add a project owned by the user
# resource "gitlab_project" "sample_project" {
#   name = "example"
# }

# # Add a hook to the project
# resource "gitlab_project_hook" "sample_project_hook" {
#   project = gitlab_project.sample_project.id
#   url     = "https://example.com/project_hook"
# }

# # Add a variable to the project
# resource "gitlab_project_variable" "sample_project_variable" {
#   project = gitlab_project.sample_project.id
#   key     = "project_variable_key"
#   value   = "project_variable_value"
# }

# # Add a deploy key to the project
# resource "gitlab_deploy_key" "sample_deploy_key" {
#   project = gitlab_project.sample_project.id
#   title   = "terraform example"
#   key     = "ssh-rsa AAAA..."
# }

# # Add a group
# resource "gitlab_group" "sample_group" {
#   name        = "example"
#   path        = "example"
#   description = "An example group"
# }

# # Add a project to the group - example/example
# resource "gitlab_project" "sample_group_project" {
#   name         = "example"
#   namespace_id = gitlab_group.sample_group.id
# }
