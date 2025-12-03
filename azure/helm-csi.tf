resource "helm_release" "csi" {
  count = local.aks.enabled ? 1 : 0

  name   = "configure-csi"
  chart  = "./charts/configure-csi"

  set = [
    {
      name  = "storageAccountName"
      value = azurerm_storage_account.file_csi[0].name
    }
  ]

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_storage_account.file_csi,
    azurerm_private_endpoint.file_csi,
    azurerm_private_dns_zone_virtual_network_link.file_csi
  ]
}