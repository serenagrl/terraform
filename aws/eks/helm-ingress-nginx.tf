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
  version          = ">= 4.12"

  values = [file("${path.module}/values/ingress-nginx.yaml")]

  depends_on = [
    helm_release.lbc,
    time_sleep.wait_for_lbc,
    aws_iam_role_policy_attachment.lbc,
    aws_eks_addon.eks_pod_identity_agent,
    # module.vpc.public_rtb,
    # module.vpc.public_subnet1,
    # module.vpc.public_subnet2,
    # aws_route_table_association.public_zone1,
    # aws_route_table_association.public_zone2,
    # aws_route_table_association.private_zone1,
    # aws_route_table_association.private_zone2,
    # module.vpc.private_rtb1,
    # module.vpc.private_rtb2,
    # aws_nat_gateway.nat_gw1,
    # aws_nat_gateway.nat_gw2,
    ]
}

data "kubernetes_service" "internal_ingress_service" {
  metadata {
    name = "ingress-nginx-controller-internal"
    namespace = helm_release.ingress_nginx.metadata[0].namespace
  }

  depends_on = [helm_release.ingress_nginx]
}
