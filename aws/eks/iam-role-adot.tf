resource "aws_iam_role" "adot" {
  name               = "${aws_eks_cluster.eks_cluster.name}-aws-adot"
  assume_role_policy = data.aws_iam_policy_document.pod_id_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_xray_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = aws_iam_role.adot.name
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.adot.name
}