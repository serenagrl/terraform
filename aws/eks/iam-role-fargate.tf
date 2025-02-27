data "aws_iam_policy_document" "fargate_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fargate_profile" {
  count = var.fargate_enabled ? 1 : 0

  name               = "${var.project}-fargate"
  assume_role_policy = data.aws_iam_policy_document.fargate_policy.json
}

resource "aws_iam_role_policy_attachment" "fargate_profile" {
  count = var.fargate_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile[0].name
}