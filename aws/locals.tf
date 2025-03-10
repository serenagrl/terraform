locals {
  region      = "ap-southeast-1"
  project     = "eks"

  ### VPC Settings ###
  vpc = {
    cidr = "10.0.0.0/16"

    subnet_cidrs = {
      public   = ["10.0.0.0/20", "10.0.16.0/20"]
      private  = ["10.0.128.0/20", "10.0.144.0/20"]
      database = ["10.0.160.0/20", "10.0.176.0/20"]
    }
  }

  ### VPN Settings ###
  vpn = {
    enabled = true

    # Valid values are "virtual_private" or "transit"
    gateway_type        = "virtual_private"

    # Set your public IP address or null to auto-acquire.
    customer_gateway_ip = null

    local_ipv4_cidr     = "192.168.0.0/24"
    tunnel1_inside_cidr = "169.254.100.0/30"
    tunnel2_inside_cidr = "169.254.101.0/30"

    # Set your keys or null to auto-generate.
    tunnel1_preshared_key = null
    tunnel2_preshared_key = null

  }

  ### EKS settings ###
  eks = {
    enabled        = true
    # Takes latest recommended if not specified.
    k8s_version    = ""
    subnet_ids     = [module.vpc.private_subnet1.id, module.vpc.private_subnet2.id]
    ami            = "AL2_x86_64"
    capacity       = "ON_DEMAND"
    instance_type  = "t3.medium"
    disk_size      = 20
    desired_nodes  = 2
    min_nodes      = 2
    max_nodes      = 6

    # Valid values are "cluster" or "karpenter"
    autoscaler_type       = "karpenter"
    internal_ingress_host = ""

    keda_enabled          = false
    keda_http_enabled     = false
    fargate_enabled       = false
    fargate_namespace     = "fargate-demo"
    argocd_enabled        = false
    dashboard_enabled     = false
  }

  ### ECR settings ###
  ecr = {
    enabled  = false
    app_name = "<Your-Application-Namespace>"
    repositories = []
  }

  ### RDS Postgres Settings ###
  postgres = {
    enabled       = true
    version       = "17.2"
    instance_type = "db.t4g.micro"
    subnet_ids    = [module.vpc.database_subnet1[0].id, module.vpc.database_subnet2[0].id]
    multi_az      = false
    initial_db    = "broadcastdb"
    username      = "postgres"
    password      = null # Set to null to auto-generate.
  }

  ### Amazon MQ RabbitMQ Broker Settings ###
  rabbitmq = {
    enabled        = true
    broker_name    = "rabbitmq"
    version        = "3.13"
    instance_type  = "mq.t3.micro" # "mq.m5.large"
    mode           = "SINGLE_INSTANCE" # "SINGLE_INSTANCE" or "CLUSTER_MULTI_AZ"
    subnet_ids     = [module.vpc.private_subnet1.id, module.vpc.private_subnet2.id]
    username       = "rabbit-admin"
    password       = null # Set to null to auto-generate.
  }

  cache = {
    enabled        = true
    cluster_name   = "redis-cluster"
    engine         = "redis" # "redis" or "valkey"
    version        = "7.2"
    instance_type  = "cache.t3.micro"
    subnet_ids     = [module.vpc.private_subnet1.id, module.vpc.private_subnet2.id]
    auth_type      = "user" # "token" or "user"
    password       = null # Set to null to auto-generate.

    # Standalone single-node - cluster_enabled=false, nodes_and_replicas=[1,0], multi_az=false
    # Multi node non-cluster - cluster_enabled=false, nodes_and_replicas=[1,2], multi_az=true
    # Multi-node group cluster - cluster_enabled=true, nodes_and_replicas=[2,1], multi_az=true
    cluster_enabled    = true
    nodes_and_replicas = [1,2]
    multi_az           = true
  }
}
