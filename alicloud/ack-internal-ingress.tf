resource "helm_release" "configure_internal_ingress" {
  count = local.ack.enabled ? 1 : 0

  name  = "configure-internal-ingress"
  chart = "./charts/configure-internal-ingress"

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    data.alicloud_cs_cluster_credential.ack
  ]
}

data "alicloud_slb_load_balancers" "internal" {
  count = local.ack.enabled && local.dns_pvtz.enabled && local.ack.ingress_pvtz_record ? 1 : 0
  name_regex = "internal-ingress"

  depends_on = [ helm_release.configure_internal_ingress ]
}

resource "alicloud_pvtz_zone_record" "dns_pvtz_record" {
  count = local.ack.enabled && local.dns_pvtz.enabled && local.ack.ingress_pvtz_record ? 1 : 0

  zone_id = alicloud_pvtz_zone.internal_zone.0.id
  rr      = "${local.project}"
  type    = "A"
  value   = data.alicloud_slb_load_balancers.internal[0].balancers[0].address
  ttl     = 60

  depends_on = [ data.alicloud_slb_load_balancers.internal ]

}