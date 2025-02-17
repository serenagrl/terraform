resource "aws_ecr_repository" "container_repositories" {
  for_each             =  local.ecr.enabled ? toset(local.ecr.repositories) : []
  name                 = "${local.ecr.app_name}/${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  tags = {
    app = local.ecr.app_name
  }
}