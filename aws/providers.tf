provider "aws" {
  region = local.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = local.eks.enabled ? module.eks[0].endpoint : ""
    cluster_ca_certificate = local.eks.enabled ? module.eks[0].ca_cert : ""
    token                  = local.eks.enabled ? module.eks[0].token: ""

    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  host                   = local.eks.enabled ? module.eks[0].endpoint : ""
  cluster_ca_certificate = local.eks.enabled ? module.eks[0].ca_cert : ""
  token                  = local.eks.enabled ? module.eks[0].token: ""

  config_path = "~/.kube/config"
}