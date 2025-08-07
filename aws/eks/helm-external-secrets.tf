resource "helm_release" "external_secrets" {
  count = var.use_secrets_manager ? 1 : 0

  name = "external-secrets"

  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  # version    = "0.19"

  depends_on = [helm_release.ingress_nginx]
}