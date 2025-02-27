resource "aws_ec2_tag" "tag_fargate_private_subnet" {
  count = var.fargate_enabled ? length(var.subnet_ids) : 0

  resource_id = var.subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.project}-cluster"
  value       = "owned"
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  count = var.fargate_enabled ? 1 : 0

  cluster_name = aws_eks_cluster.eks_cluster.name
  fargate_profile_name = "${var.fargate_namespace}-profile"
  pod_execution_role_arn = aws_iam_role.fargate_profile[0].arn

  subnet_ids = var.subnet_ids

  selector {
    namespace = "${var.fargate_namespace}"
  }

}