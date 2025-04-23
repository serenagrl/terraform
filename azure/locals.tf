locals {
  subscription_id = "<Your-azure-subscription-id>"
  region          = "southeastasia"
  project         = "aks"

  vnet = {
    cidr = "10.0.0.0/16"
    subnet_cidrs = {
      aks      = "10.0.16.0/20"
      database = "10.0.32.0/20"
      services = "10.0.48.0/20"
    }
  }

  vpn = {
    enabled              = true
    local_gateway_ip     = ""
    local_address_space  = ["192.168.0.0/24"]
    subnet_cidr          = "10.0.64.0/24"
    shared_key           = "<super-secret-shared-key>" # Create your own key.
    vnet_gateway_sku     = "VpnGw1AZ"
    dns_resolver_enabled = true
    dns_resolver_cidr    = "10.0.65.0/24"
  }

  aks = {
    enabled              = true
    sku_tier             = "Free"
    vm_size              = "Standard_B2als_v2" #"Standard_D2_v2"
    os_sku               = "AzureLinux"
    zones                = [1, 2, 3]
    k8s_version          = "1.32"
    pod_cidr             = "172.168.0.0/16"
    service_cidr         = "10.10.0.0/16" # Must specify together with dns_service_ip
    dns_service_ip       = "10.10.0.10"   # Must specify together with service cidr
    auto_scaling_enabled = true
    node_count           = 2
    min_count            = 2
    max_count            = 4

    image_cleaner_enabled        = true
    image_cleaner_interval_hours = 24
    azure_policy_enabled         = false
    karpenter_enabled            = false
    acr_enabled                  = true
    argocd_enabled               = true
    rabbitmq_enabled             = true
    rabbitmq_vm_size             = "Standard_B2als_v2"
  }

  postgres = {
    enabled     = true
    version     = "16"
    sku         = "B_Standard_B1ms"
    server_name = "${local.project}-postgres" # Must be unique name across azure
    username    = "postgres"
    password    = null # Set to null to auto-generate.
    extensions  = "POSTGRES_FDW,UUID-OSSP,PGCRYPTO,PG_TRGM"
  }

  redis = {
    enabled             = true
    name                = "${local.project}-redis" # Must be unique name across azure
    sku                 = "Basic" # "Basic", "Standard" or "Premium".

    # Basic & Standard tier supported capacity from 0 to 6.
    # Premium tier supported capacity from 1 to 5.
    capacity            = 0

    # 3 shards can only support a maximum of 1 replica.
    # 2 shards can only support a maximum of 2 replicas.
    # 1 shard can only support a maximum of 3 replicas.
    shards              = null # Only for Premium Tier.
    replicas_per_master = 0 # Only for Premium Tier.
  }

  telemetry = {
    enabled                     = true
    app_insights_retention_days = 30
  }
}