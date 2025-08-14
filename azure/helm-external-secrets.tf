resource "helm_release" "external_secrets" {
  count = local.aks.external_secrets_enabled ? 1 : 0

  name = "external-secrets"

  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  # version    = "0.19"

  depends_on = [azurerm_kubernetes_cluster.aks]
}