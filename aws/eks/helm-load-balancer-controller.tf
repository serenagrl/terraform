resource "helm_release" "lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  # version    = "1.11"
  wait       =  true

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks_cluster.name
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.lbc,
    aws_eks_addon.coredns,
    helm_release.metrics_server
  ]
}