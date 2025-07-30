resource "helm_release" "rabbitmq_cluster_operator" {
  count = local.aks.enabled && local.aks.rabbitmq_enabled ? 1 :0
  name  = "rabbitmq"

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "rabbitmq-cluster-operator"
  namespace        = "rabbitmq"
  create_namespace = true
  # version          = "4.4"
  wait             = true

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.rabbitmq,
    azurerm_nat_gateway_public_ip_association.nat_ip_assoc,
    azurerm_subnet_nat_gateway_association.aks_subnet_nat_assoc
  ]

}

# Custom helm-chart to create rabbitmq cluster.
resource "helm_release" "rabbitmq_cluster" {
  count = local.aks.enabled && local.aks.rabbitmq_enabled ? 1 : 0

  name             = "rabbitmq-cluster"
  chart            = "./charts/create-rabbitmq-cluster"
  namespace        = "rabbitmq-cluster"
  create_namespace = true

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.rabbitmq,
    helm_release.rabbitmq_cluster_operator,
    helm_release.nginx-internal
  ]
}