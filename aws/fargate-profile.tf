resource "aws_ec2_tag" "tag_fargate_private_subnet1" {
  count = local.fargate.enabled ? 1 : 0

  resource_id = aws_subnet.private_subnet1.id
  key         = "kubernetes.io/cluster/${local.project}-cluster"
  value       = "owned"
}

resource "aws_ec2_tag" "tag_fargate_private_subnet2" {
  count = local.fargate.enabled ? 1 : 0

  resource_id = aws_subnet.private_subnet2.id
  key         = "kubernetes.io/cluster/${local.project}-cluster"
  value       = "owned"
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  count = local.fargate.enabled ? 1 : 0

  cluster_name = aws_eks_cluster.eks_cluster.name
  fargate_profile_name = "${local.fargate.namespace}-profile"
  pod_execution_role_arn = aws_iam_role.fargate_profile[0].arn

  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
    ]

  selector {
    namespace = "${local.fargate.namespace}"
  }

}