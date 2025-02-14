resource "aws_ecr_repository" "container_repositories" {
  for_each             =  local.demo.enabled ? toset(local.demo.repositories) : []
  name                 = "${local.demo.app_name}/${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  tags = {
    app = local.demo.app_name
  }
}