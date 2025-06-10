resource "alicloud_vpc" "vpc" {
  vpc_name          = "${local.project}-vpc"
  description       = "Virtual Private Cloud for ${local.project}"
  cidr_block        = local.vpc.cidr
  resource_group_id = alicloud_resource_manager_resource_group.ack.id

  depends_on = [
    alicloud_ram_role.ram_roles,
    alicloud_ram_role_policy_attachment.ram_roles_policy_attachment
  ]
}