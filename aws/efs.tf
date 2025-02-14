resource "aws_efs_file_system" "eks" {
  creation_token = "eks"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

}

resource "aws_efs_mount_target" "private_zone1" {
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = aws_subnet.private_subnet1.id
  security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
}

resource "aws_efs_mount_target" "private_zone2" {
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = aws_subnet.private_subnet2.id
  security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
}