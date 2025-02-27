resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.eks_nodegroup]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "aws-efs-csi-driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-efs-csi-driver"

  depends_on = [
    aws_eks_node_group.eks_nodegroup,
    aws_eks_addon.eks_pod_identity_agent
  ]
}

resource "aws_eks_addon" "adot" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "adot"

  depends_on = [
    helm_release.cert_manager,
    aws_eks_addon.eks_pod_identity_agent
  ]
}