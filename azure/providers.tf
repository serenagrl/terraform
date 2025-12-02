provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # version = ">= 4.13"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      # version = ">= 2.36"
    }
    helm = {
      source  = "hashicorp/helm"
      # version = ">= 3"
    }
    azapi = {
      source = "Azure/azapi"
      # version = ">= 2.3"
    }
    curl = {
      source = "anschoewe/curl"
      # version = ">= 1.0.2"
    }
    random = {
      source = "hashicorp/random"
      # version = ">= 3.6.3"
    }
  }
}

resource "local_file" "kubeconfig" {
  count = local.aks.enabled ? 1 : 0
  
  filename     = pathexpand("~/.kube/${local.project}-cluster")
  content      = azurerm_kubernetes_cluster.aks[0].kube_config_raw

  depends_on   = [azurerm_kubernetes_cluster.aks]
}

provider "kubernetes" {
  config_path = "~/.kube/${local.project}-cluster"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/${local.project}-cluster"
  }
}