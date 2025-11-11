resource "azurerm_kubernetes_cluster_node_pool" "rabbitmq" {
  count = local.aks.enabled && local.aks.rabbitmq_enabled ? 1 :0

  name                   = "rabbitmq"
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks[0].id
  vm_size                = local.aks.rabbitmq_vm_size
  vnet_subnet_id         = azurerm_subnet.aks.id
  orchestrator_version   = local.aks.k8s_version
  node_public_ip_enabled = false
  zones                  = local.aks.rabbitmq_zones
  auto_scaling_enabled   = true
  node_count             = 3
  min_count              = 3
  max_count              = 5

  node_labels = {
    role = "rabbitmq-node"
  }

  node_taints = [
    "rabbitmq-cluster:NoSchedule"
  ]

  lifecycle {
    ignore_changes = [node_count, upgrade_settings]
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_nat_gateway_public_ip_association.nat_ip_assoc,
    azurerm_subnet_nat_gateway_association.aks_subnet_nat_assoc
  ]
}