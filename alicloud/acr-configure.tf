data "alicloud_cr_ee_instances" "acr" {
  count = local.acr.configure ? 1 : 0

  name_regex = local.acr.registry_name
}

# NOTE: Managed ACR Credential Helper can only be used on ACK Pro version.
resource "alicloud_cs_kubernetes_addon" "aliyun-acr-credential-helper" {
  count = local.acr.configure && local.ack.enabled ? 1 : 0

  cluster_id = alicloud_cs_managed_kubernetes.ack[0].id
  name       = "managed-aliyun-acr-credential-helper"
  config     = jsonencode({
    watchNamespace = "all"
    AcrInstanceInfo = [{
      instanceId = data.alicloud_cr_ee_instances.acr[0].instances[0].id
      regionId = local.region
    }]
  })
}

# Note: Alicloud does not support concurrent creation of acl policy.
resource "alicloud_cr_endpoint_acl_policy" "nat1" {
  count = local.acr.configure ? 1 : 0

  instance_id   = data.alicloud_cr_ee_instances.acr[0].instances[0].id
  entry         = "${alicloud_eip_address.nats[0].ip_address}/32"
  description   = "NAT Gateway IP Address"
  module_name   = "Registry"
  endpoint_type = "internet"
}

resource "alicloud_cr_endpoint_acl_policy" "nat2" {
  count = local.acr.configure ? 1 : 0

  instance_id   = data.alicloud_cr_ee_instances.acr[0].instances[0].id
  entry         = "${alicloud_eip_address.nats[1].ip_address}/32"
  description   = "NAT Gateway IP Address"
  module_name   = "Registry"
  endpoint_type = "internet"

  depends_on = [ alicloud_cr_endpoint_acl_policy.nat1 ]
}

resource "alicloud_cr_endpoint_acl_policy" "customer_gateway_ip" {
  count = local.acr.configure && local.vpn.enabled ? 1 : 0

  instance_id   = data.alicloud_cr_ee_instances.acr[0].instances[0].id
  entry         = "${alicloud_vpn_customer_gateway.on_premise[0].ip_address}/32"
  description   = "Customer Gateway IP Address (for Harbor Replication)"
  module_name   = "Registry"
  endpoint_type = "internet"

  depends_on = [ alicloud_cr_endpoint_acl_policy.nat2 ]
}

resource "alicloud_cr_vpc_endpoint_linked_vpc" "cr_ee_vswitch_link" {
  count = local.acr.configure && local.vpc.create_service_vswitch ? 1 : 0

  instance_id = data.alicloud_cr_ee_instances.acr[0].instances[0].id
  vpc_id      = alicloud_vpc.vpc.id
  vswitch_id  = alicloud_vswitch.service_vswitch[0].id
  module_name = "Registry"

  depends_on = [ alicloud_vswitch.service_vswitch ]
}