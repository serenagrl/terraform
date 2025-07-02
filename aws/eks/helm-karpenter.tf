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
  # version    = "1.5"

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.controller[0].arn
    },
    {
      name  = "settings.clusterName"
      value = aws_eks_cluster.eks_cluster.name
    }
  ]

  depends_on = [
    aws_ec2_tag.tag_eks_cluster_security_group,
    aws_iam_role_policy_attachment.controller,
    helm_release.ingress_nginx
  ]
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/image_id"

  depends_on = [
    helm_release.karpenter,
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodegroup
  ]
}

resource "helm_release" "configure_karpenter" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  name  = "configure-karpenter"
  chart = "${path.module}/charts/configure-karpenter"

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks_cluster.name
    },
    {
      name  = "amiId"
      value = data.aws_ssm_parameter.ami.value
    }
  ]

  depends_on = [
    helm_release.karpenter,
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_nodegroup
  ]
}