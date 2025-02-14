resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.project}-nodes"
  node_role_arn   = aws_iam_role.nodegroup_role.arn

  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  ami_type       = "${local.node_config.ami}"
  capacity_type  = "${local.node_config.capacity}"
  instance_types = "${local.node_config.instance_types}"
  disk_size      = "${local.node_config.disk_size}"

  scaling_config {
    min_size     = "${local.node_config.scaling.min}"
    max_size     = "${local.node_config.scaling.max}"
    desired_size = "${local.node_config.scaling.desired}"
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_policy,
    aws_iam_role_policy_attachment.amazon_efs_csi_driver_policy
   ]

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }
}