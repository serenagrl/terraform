# resource "helm_release" "cert_manager" {
#   name = "cert-manager"

#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#   version          = "v1.16.2"

#   set {
#     name  = "crds.enabled"
#     value = "true"
#   }

#   set {
#     name  = "crds.keep"
#     value = "false"
#   }

# }