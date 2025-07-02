resource "helm_release" "cluster_autoscaler" {
  count = upper(var.autoscaler_type) == "CLUSTER" ? 1 : 0

  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  # version    = "9.43.2"

  set = [
    {
      name  = "cloudProvider"
      value = "aws"
    },
    {
      name  = "awsRegion"
      value = "${var.region}"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    },
    {
      name  = "autoDiscovery.clusterName"
      value = aws_eks_cluster.eks_cluster.name
    },
    {
      name  = "extraArgs.scale-down-unneeded-time"
      value = "1m"
    },
    {
      name  = "extraArgs.scale-down-unready-time"
      value = "1m"
    },
    {
      name  = "extraArgs.scale-down-delay-after-add"
      value = "1m"
    }
  ]

  depends_on = [helm_release.ingress_nginx]
}