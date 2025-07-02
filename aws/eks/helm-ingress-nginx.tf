resource "time_sleep" "wait_for_lbc" {
  depends_on = [helm_release.lbc]
  create_duration = "30s"
}

resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  # version          = "4.12"

  values = [file("${path.module}/values/ingress-nginx.yaml")]

  depends_on = [
    helm_release.lbc,
    time_sleep.wait_for_lbc,
    aws_iam_role_policy_attachment.lbc,
    aws_eks_addon.eks_pod_identity_agent,
  ]
}

data "kubernetes_service" "internal_ingress_service" {
  metadata {
    name = "ingress-nginx-controller-internal"
    namespace = helm_release.ingress_nginx.metadata.namespace
  }

  depends_on = [helm_release.ingress_nginx]
}
