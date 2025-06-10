data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "controller_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole","sts:TagSession"]
  }
}

resource "aws_iam_role" "controller" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0
  name                  = "${aws_eks_cluster.eks_cluster.name}-karpenter-controller"
  assume_role_policy    = data.aws_iam_policy_document.controller_assume_role.json
}

resource "aws_iam_policy" "controller" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  policy = templatefile("${path.module}/iam/KarpenterController.json", {
    partition    = data.aws_partition.current.partition
    region       = var.region
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_role    = aws_iam_role.nodegroup_role.arn
    account_id   = data.aws_caller_identity.current.account_id
  })
  name   = "${aws_eks_cluster.eks_cluster.name}-karpenter-controller"
}

resource "aws_iam_role_policy_attachment" "controller" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  role       = aws_iam_role.controller[0].name
  policy_arn = aws_iam_policy.controller[0].arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.controller[0].arn
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core_policy" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_ec2_policy" {
  count = upper(var.autoscaler_type) == "KARPENTER" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
  role       = aws_iam_role.nodegroup_role.name
}