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
    aws_route_table.public_rtb,
    aws_subnet.public_subnet1,
    aws_subnet.public_subnet2,
    aws_route_table_association.public_zone1,
    aws_route_table_association.public_zone2,
    aws_route_table_association.private_zone1,
    aws_route_table_association.private_zone2,
    aws_route_table.private_rtb1,
    aws_route_table.private_rtb2,
    aws_nat_gateway.nat_gw1,
    aws_nat_gateway.nat_gw2,
    ]
}