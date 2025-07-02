terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      # version = ">= 3"
    }
    alicloud = {
      source = "aliyun/alicloud"
      # version = ">= 1.252"
    }
    curl = {
      source = "anschoewe/curl"
      # version = ">= 1.0.2"
    }
  }
}

provider "alicloud" {
  region     = local.region
  # profile    = "default"
  access_key = local.access_key
  secret_key = local.secret_key
}

data "alicloud_cs_cluster_credential" "ack" {
  count = local.ack.enabled ? 1 : 0

  cluster_id = alicloud_cs_managed_kubernetes.ack[0].id
  output_file = "~/.kube/${local.project}-cluster"

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/${local.project}-cluster"
  }
}

provider "kubernetes" {
  config_paths = ["~/.kube/${local.project}-cluster"]
}