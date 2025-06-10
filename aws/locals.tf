locals {
  region      = "ap-southeast-1"
  project     = "eks"

  ### VPC Settings ###
  vpc = {
    cidr = "10.0.0.0/16"

    subnet_cidrs = {
      public   = ["10.0.0.0/20", "10.0.16.0/20"]
      private  = ["10.0.64.0/20", "10.0.80.0/20"]
    }
  }

  ### VPN Settings ###
  vpn = {
    enabled = false

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
    subnet_ids     = module.vpc.private_subnets.*.id
    ami            = "AL2023_x86_64_STANDARD"
    capacity       = "ON_DEMAND"
    instance_type  = "t3.medium"
    disk_size      = 20
    desired_nodes  = 2
    min_nodes      = 2
    max_nodes      = 6

    # Valid values are "cluster" or "karpenter"
    autoscaler_type       = "cluster"
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

  ### Amazon RDS Settings ###
  rds = {
    enabled        = false
    engine         = "postgres"
    engine_version = "17.2"
    instance_type  = "db.t4g.micro"
    username      = "postgres"
    password      = null # Set to null to auto-generate.
    subnet_cidrs  = ["10.0.112.0/20", "10.0.128.0/20"]
    multi_az      = true

    ### RDS Postgres Settings ###
    postgres = {
      initial_db    = "broadcastdb"
    }
  }

  ### Amazon MQ RabbitMQ Broker Settings ###
  rabbitmq = {
    enabled        = false
    broker_name    = "rabbitmq"
    version        = "3.13"
    instance_type  = "mq.t3.micro" # "mq.m5.large"
    mode           = "SINGLE_INSTANCE" # "SINGLE_INSTANCE" or "CLUSTER_MULTI_AZ"
    subnet_ids     = module.vpc.private_subnets.*.id
    username       = "rabbit-admin"
    password       = null # Set to null to auto-generate.
  }

  ### Amazon Elasticache Settings ###
  cache = {
    enabled        = false
    cluster_name   = "redis-cluster"
    engine         = "redis" # "redis" or "valkey"
    version        = "7.2"
    instance_type  = "cache.t3.micro"
    subnet_ids     = module.vpc.private_subnets.*.id
    auth_type      = "user" # "token" or "user"
    password       = null # Set to null to auto-generate.

    # Standalone single-node - cluster_enabled=false, nodes_and_replicas=[1,0], multi_az=false
    # Multi node non-cluster - cluster_enabled=false, nodes_and_replicas=[1,2], multi_az=true
    # Multi-node group cluster - cluster_enabled=true, nodes_and_replicas=[2,1], multi_az=true
    cluster_enabled    = true
    nodes_and_replicas = [1,1]
    multi_az           = true
  }
}
