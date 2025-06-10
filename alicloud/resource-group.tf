resource "alicloud_resource_manager_resource_group" "ack" {
  resource_group_name = "${local.project}-resources"
  display_name        = "Resource Group for ${local.project}"
}