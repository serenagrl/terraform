resource "aws_ec2_tag" "tag_eks_cluster_security_group" {
  count = local.autoscaler == "karpenter" ? 1 : 0

  resource_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.eks_cluster.name

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_ec2_tag" "tag_karpenter_private_subnet1" {
  count = local.autoscaler == "karpenter" ? 1 : 0

  resource_id = aws_subnet.private_subnet1.id
  key         = "karpenter.sh/discovery"
  value       = "${local.project}-cluster"
}

resource "aws_ec2_tag" "tag_karpenter_private_subnet2" {
  count = local.autoscaler == "karpenter" ? 1 : 0

  resource_id = aws_subnet.private_subnet2.id
  key         = "karpenter.sh/discovery"
  value       = "${local.project}-cluster"
}

resource "helm_release" "karpenter" {
  count = local.autoscaler == "karpenter" ? 1 : 0

  name = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  namespace  = "kube-system"
  version    = ">= 1.2.1"

  set {
    name  = "settings.clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }

  depends_on = [
    aws_ec2_tag.tag_eks_cluster_security_group,
    aws_iam_role_policy_attachment.controller,
    helm_release.ingress_nginx
  ]
}