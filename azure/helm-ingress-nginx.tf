# resource "helm_release" "ingress_nginx" {
#   name = "ingress-nginx"

#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "ingress-nginx"
#   create_namespace = true
#   version          = ">= 4.11.3"

#   values = [file("${path.module}/values/ingress-nginx.yaml")]

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }