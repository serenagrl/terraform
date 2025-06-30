resource "alicloud_security_group" "ack" {
  count = local.ack.enabled ? 1 : 0

  security_group_name = "${local.project}-cluster-security-group"
  vpc_id              = alicloud_vpc.vpc.id

  tags = local.karpenter_tag
}

resource "alicloud_security_group_rule" "ack_icmp" {
  count = local.ack.enabled ? 1 : 0

  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 100
  security_group_id = alicloud_security_group.ack[0].id
  cidr_ip           = "0.0.0.0/0"
}
