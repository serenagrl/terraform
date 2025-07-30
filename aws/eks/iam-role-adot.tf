data "aws_iam_policy_document" "adot" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "adot" {
  name               = "${aws_eks_cluster.eks_cluster.name}-aws-adot"
  assume_role_policy = data.aws_iam_policy_document.adot.json
}

resource "aws_iam_role_policy_attachment" "aws_xray_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = aws_iam_role.adot.name
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.adot.name
}