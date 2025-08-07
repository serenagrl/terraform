resource "aws_iam_role" "secrets_manager" {
  count = var.use_secrets_manager ? 1 : 0

  name               = "${aws_eks_cluster.eks_cluster.name}-secrets-manager"
  assume_role_policy = data.aws_iam_policy_document.pod_id_policy.json
}

resource "aws_iam_policy" "secrets_manager" {
  count = var.use_secrets_manager ? 1 : 0

  policy = templatefile("${path.module}/iam/SecretsManager.json", {
    region       = var.region
    account_id   = data.aws_caller_identity.current.account_id
  })
  name   = "ExternalSecretsManager"
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  count = var.use_secrets_manager ? 1 : 0

  policy_arn = aws_iam_policy.secrets_manager[0].arn
  role       = aws_iam_role.secrets_manager[0].name
}

resource "aws_eks_pod_identity_association" "secrets_manager" {
  count = var.use_secrets_manager ? 1 : 0

  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.secrets_manager[0].arn
}