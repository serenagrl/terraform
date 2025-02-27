resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project}-nodes"
  node_role_arn   = aws_iam_role.nodegroup_role.arn

  subnet_ids      = var.subnet_ids

  ami_type        = var.ami
  capacity_type   = var.capacity
  instance_types  = [var.instance_type]
  disk_size       = var.disk_size

  scaling_config {
    min_size      = var.min_nodes
    max_size      = var.max_nodes
    desired_size  = var.desired_nodes
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_policy,
    aws_iam_role_policy_attachment.amazon_efs_csi_driver_policy,
    aws_eks_cluster.eks_cluster,
   ]

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }
}