resource "aws_ec2_tag" "tag_eks_cluster_security_group" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  resource_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.eks_cluster.name

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_ec2_tag" "tag_karpenter_private_subnet" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? length(var.subnet_ids) : 0

  resource_id = var.subnet_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = "${var.project}-cluster"
}

resource "helm_release" "karpenter" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

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