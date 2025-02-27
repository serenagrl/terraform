
terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# data "aws_eks_cluster" "eks" {
#   name = aws_eks_cluster.eks_cluster.name
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = aws_eks_cluster.eks_cluster.name
# }

# provider "helm" {
#   alias = "main"
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks.token

#     config_path = "~/.kube/config"
#   }
# }

# provider "kubernetes" {
#   alias = "main"

#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks.token

#   config_path = "~/.kube/config"
# }