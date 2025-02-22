locals {
  region      = "ap-southeast-1"
  project     = "eks"

  # Takes latest recommended if not specified.
  k8s_version = ""

  ### VPC Settings ###
  vpc_cidr    = "10.0.0.0/16"
  subnets = {
    public_cidrs = ["10.0.0.0/20", "10.0.16.0/20"]
    private_cidrs = ["10.0.128.0/20", "10.0.144.0/20"]
    database_cidrs = ["10.0.160.0/20", "10.0.176.0/20"]
  }

  ### EKS Nodegroup Settings ###
  node_config = {
    ami            = "AL2_x86_64"
    capacity       = "ON_DEMAND"
    instance_types = ["t3.medium"]
    disk_size      = 20
    scaling = {
        desired = 2
        min     = 2
        max     = 6
    }
  }

  # Valid values are "cluster" or "karpenter"
  autoscaler = "karpenter"

  keda = {
    enabled = false
    http_addon = false
  }

  ### Fargate Settings ###
  fargate = {
    enabled = false
    namespace = "fargate-demo"
  }

  ### VPN Settings ###
  vpn = {
    enabled = true

    # Valid values are "virtual" or "transit"
    gateway_type        = "virtual"

    # Set your public IP address or null to auto-acquire.
    customer_gateway_ip = null

    local_ipv4_cidr     = "192.168.0.0/24"
    tunnel1_inside_cidr = "169.254.100.0/30"
    tunnel2_inside_cidr = "169.254.101.0/30"

    # Set your keys or null to auto-generate.
    tunnel1_preshared_key = null
    tunnel2_preshared_key = null

  }

  ### ECR settings ###
  ecr = {
    enabled  = false
    app_name = "<Your-Application-Namespace>"
    repositories = []
  }

  ### RDS Postgres Settings ###
  postgres = {
    enabled       = false
    version       = "17.2"
    instance_type = "db.t4g.micro"
    subnets       = [aws_subnet.database_subnet1[0].id, aws_subnet.database_subnet2[0].id]
    multi_az      = false
    initial_db    = "broadcastdb"
    username      = "postgres"
    password      = null # Set to null to auto-generate.
  }

  ### Amazon MQ RabbitMQ Broker Settings ###
  rabbitmq = {
    enabled        = false
    broker_name    = "rabbitmq"
    version        = "3.13"
    instance_type  = "mq.t3.micro" # "mq.m5.large"
    mode           = "SINGLE_INSTANCE" # "SINGLE_INSTANCE" or "CLUSTER_MULTI_AZ"
    subnets        = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

    admin_username = "rabbit-admin"
    admin_password = null # Set to null to auto-generate.
  }

  cache = {
    enabled = false
    cluster_name   = "redis-cluster"
    engine         = "redis" # "redis" or "valkey"
    version        = "7.1"
    instance_type  = "cache.t3.micro"
    subnets        = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    auth_type      = "user" # "token" or "user"
    password       = null # Set to null to auto-generate.

    # Standalone single-node - cluster_enabled=false, nodes_and_replicas=[1,0], multi_az=false
    # Multi node non-cluster - cluster_enabled=false, nodes_and_replicas=[1,2], multi_az=true
    # Multi-node group cluster - cluster_enabled=true, nodes_and_replicas=[2,1], multi_az=true
    cluster_enabled    = false
    nodes_and_replicas = [1,0]
    multi_az           = false
  }
}
