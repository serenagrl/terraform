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
    enabled = true
    http_addon = true
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
    enabled  = true
    app_name = "<Your-Application-Namespace>"
    # List of repositories that you want to be created.
    repositories = []
  }

  ### RDS Postgres Settings ###
  postgres = {
    enabled       = true
    version       = "17.2"
    instance_type = "db.t4g.micro"
    subnets       = [aws_subnet.database_subnet1[0].id,
                     aws_subnet.database_subnet2[0].id
                    ]
    multi_az      = false
    initial_db    = "broadcastdb"
    username      = "postgres"
    # Set your password or null to auto-generate.
    password      = null
  }

  ### Amazon MQ RabbitMQ Broker Settings ###
  rabbitmq = {
    enabled        = true
    version        = "3.13"
    instance_type  = "mq.m5.large" # "mq.t3.micro"
    mode           = "CLUSTER_MULTI_AZ" # "SINGLE_INSTANCE" or "CLUSTER_MULTI_AZ"
    subnets        = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    admin_username = "rabbit-admin"
    # Set your password or null to auto-generate.
    admin_password = null
  }
}
