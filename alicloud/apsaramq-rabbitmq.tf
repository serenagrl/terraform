variable "rabbitmq_roles" {
  type = list(string)
  default = [ "monitoring.amqp.aliyuncs.com", "network.amqp.aliyuncs.com" ]
}

resource "alicloud_resource_manager_service_linked_role" "rabbitmq_roles" {
  for_each = { for r in var.rabbitmq_roles : r => r if local.rabbitmq.enabled && local.rabbitmq.create_roles }

  service_name = each.value
}

# WARNING: Does not remove instances when running 'terraform destroy'. Please remove manually at portal.
# Read here: #https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/amqp_instance
resource "alicloud_amqp_instance" "rabbitmq" {
  count = local.rabbitmq.enabled ? 1 : 0

  instance_name          = local.rabbitmq.instance_name
  payment_type           = "PayAsYouGo"
  serverless_charge_type = "onDemand"
  support_eip            = false

  depends_on = [ alicloud_resource_manager_service_linked_role.rabbitmq_roles ]
}

resource "alicloud_amqp_static_account" "rabbitmq" {
  count = local.rabbitmq.enabled ? 1 : 0

  instance_id = alicloud_amqp_instance.rabbitmq[0].id
  access_key  = local.rabbitmq.access_key
  secret_key  = local.rabbitmq.secret_key

  depends_on = [ alicloud_amqp_instance.rabbitmq ]
}

resource "alicloud_amqp_virtual_host" "default" {
  count = local.rabbitmq.enabled ? 1 : 0

  instance_id       = alicloud_amqp_instance.rabbitmq[0].id
  virtual_host_name = "/"

  depends_on = [ alicloud_amqp_instance.rabbitmq ]
}

output "rabbitmq_user" {
  value = try(alicloud_amqp_static_account.rabbitmq[0].user_name, "")
  description = "The user account for rabbitmq account that was created."

  depends_on = [ alicloud_amqp_static_account.rabbitmq ]
}

output "rabbitmq_password" {
  value = try(alicloud_amqp_static_account.rabbitmq[0].password, "")
  description = "The password for rabbitmq account that was created."

  depends_on = [ alicloud_amqp_static_account.rabbitmq ]
}