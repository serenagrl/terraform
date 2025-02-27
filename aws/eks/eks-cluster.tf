resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project}-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "${var.k8s_version}"

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
  ]

}