resource "kubernetes_service_account_v1" "storage_sa" {
  metadata {
    name = "efs-csi-controller-sa"
  }
}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs-storage"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [
    aws_eks_addon.aws-efs-csi-driver,
    kubernetes_service_account_v1.storage_sa
  ]

}