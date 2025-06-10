terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = ">= 1.247"
    }
    curl = {
      source = "anschoewe/curl"
      version = ">= 1.0.2"
    }
  }
}

provider "alicloud" {
  region     = local.region
  access_key = local.access_key
  secret_key = local.secret_key
}

data "alicloud_cs_cluster_credential" "ack" {
  count = local.ack.enabled ? 1 : 0

  cluster_id = alicloud_cs_managed_kubernetes.ack[0].id
  output_file = "~/.kube/${local.project}-cluster"

  depends_on = [
    alicloud_cs_managed_kubernetes.ack
  ]
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${local.project}-cluster"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/${local.project}-cluster"
}