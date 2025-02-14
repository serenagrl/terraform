resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.project}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${local.project}-cluster"

  kubernetes_version        = local.k8s_version
  automatic_upgrade_channel = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.project}-nodes"

  sku_tier = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  http_application_routing_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    dns_service_ip = local.dns_service_ip
    service_cidr   = local.service_cidr
  }

  default_node_pool {
    name                 = "${local.project}nodes"
    # vm_size              = "Standard_D2_v2"
    vm_size              = "Standard_B2als_v2"
    vnet_subnet_id       = azurerm_subnet.private.id
    orchestrator_version = local.k8s_version

    zones                =  [1, 2, 3]
    auto_scaling_enabled = true
    node_count           = 2
    min_count            = 2
    max_count            = 4

    node_labels = {
      role = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}