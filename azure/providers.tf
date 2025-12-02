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

provider "helm" {
  kubernetes = {
    host                   = local.aks.enabled ? azurerm_kubernetes_cluster.aks[0].kube_config.0.host : ""
    client_certificate     = local.aks.enabled ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config.0.client_certificate) : ""
    client_key             = local.aks.enabled ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config.0.client_key) : ""
    cluster_ca_certificate = local.aks.enabled ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config.0.cluster_ca_certificate) : ""
    config_path = "~/.kube/config"
  }
}