locals {
  region      = "southeastasia"
  project     = "aks"
  k8s_version = "1.31"
  vnet_cidr   = "10.0.0.0/16"
  subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20"]

  dns_service_ip = "10.0.64.10"
  service_cidr   = "10.0.64.0/20"
}