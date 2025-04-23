resource "azurerm_kubernetes_cluster" "aks" {
  count = local.aks.enabled ? 1 : 0

  name                = "${local.project}-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${local.project}-cluster"

  sku_tier = local.aks.sku_tier
  kubernetes_version        = local.aks.k8s_version
  automatic_upgrade_channel = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.project}-nodes"

  image_cleaner_enabled        = local.aks.image_cleaner_enabled
  image_cleaner_interval_hours = local.aks.image_cleaner_interval_hours
  azure_policy_enabled         = local.aks.azure_policy_enabled

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  http_application_routing_enabled = false

  web_app_routing {
    dns_zone_ids = []
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    network_plugin_mode = "overlay"
    service_cidr        = local.aks.service_cidr
    dns_service_ip      = local.aks.dns_service_ip
    pod_cidr            = local.aks.pod_cidr
    outbound_type       = "userAssignedNATGateway"
  }

  default_node_pool {
    name                   = "${local.project}nodes"
    vm_size                = local.aks.vm_size
    vnet_subnet_id         = azurerm_subnet.aks.id
    zones                  = local.aks.zones
    orchestrator_version   = local.aks.k8s_version
    os_sku                 = local.aks.os_sku
    node_public_ip_enabled = false

    auto_scaling_enabled = local.aks.karpenter_enabled ? false : local.aks.auto_scaling_enabled
    node_count           = local.aks.node_count
    min_count            = !local.aks.karpenter_enabled && local.aks.auto_scaling_enabled ? local.aks.min_count : null
    max_count            = !local.aks.karpenter_enabled && local.aks.auto_scaling_enabled ? local.aks.max_count : null

    node_labels = {
      role = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].upgrade_settings
    ]
  }

  depends_on = [
    azurerm_subnet.aks,
    azurerm_subnet_nat_gateway_association.aks_subnet_nat_assoc
  ]
}

resource "azurerm_role_assignment" "aks_load_balancer_role" {
  count = local.aks.enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = azurerm_subnet.aks.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_rg_sc_contributor_role" {
  count = local.aks.enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  role_definition_name             = "Storage Account Contributor"
  scope                            = azurerm_resource_group.aks.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_rg_dns_contributor_role" {
  count = local.aks.enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  role_definition_name             = "Private DNS Zone Contributor"
  scope                            = azurerm_resource_group.aks.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_kubelet_load_balancer_role" {
  count = local.aks.enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  role_definition_name             = "Network Contributor"
  scope                            = azurerm_subnet.aks.id
  skip_service_principal_aad_check = true
}