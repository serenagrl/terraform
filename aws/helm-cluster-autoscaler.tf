resource "helm_release" "cluster_autoscaler" {
  count = local.autoscaler == "cluster" ? 1 : 0

  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = ">= 9.43.2"

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = "${local.region}"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "1m"
  }

  set {
    name  = "extraArgs.scale-down-unready-time"
    value = "1m"
  }

  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "1m"
  }

  depends_on = [helm_release.ingress_nginx]
}