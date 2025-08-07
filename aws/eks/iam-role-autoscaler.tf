data "aws_iam_policy_document" "custom_autoscaler_policy" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = upper(var.autoscaler_type) == "CLUSTER" ? 1 : 0

  name = "${aws_eks_cluster.eks_cluster.name}-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.pod_id_policy.json
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count = upper(var.autoscaler_type) == "CLUSTER" ? 1 : 0

  name = "${aws_eks_cluster.eks_cluster.name}-autoscaler"
  policy = data.aws_iam_policy_document.custom_autoscaler_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count = upper(var.autoscaler_type) == "CLUSTER" ? 1 : 0

  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
  role       = aws_iam_role.cluster_autoscaler[0].name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  count = upper(var.autoscaler_type) == "CLUSTER" ? 1 : 0

  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler[0].arn
}