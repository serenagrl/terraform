module "vpc" {
  source = "./vpc"

  region       = local.region
  project      = local.project
  vpc_cidr     = local.vpc.cidr
  subnet_cidrs = local.vpc.subnet_cidrs
}

module "eks" {
  source = "./eks"

  count             = local.eks.enabled ? 1 : 0
  project           = local.project
  region            = local.region

  vpc_id            = module.vpc.id
  subnet_ids        = local.eks.subnet_ids
  k8s_version       = local.eks.k8s_version

  ami               = local.eks.ami
  capacity          = local.eks.capacity
  instance_type     = local.eks.instance_type
  disk_size         = local.eks.disk_size
  desired_nodes     = local.eks.desired_nodes
  min_nodes         = local.eks.min_nodes
  max_nodes         = local.eks.max_nodes

  autoscaler_type   = local.eks.autoscaler_type

  keda_enabled      = local.eks.keda_enabled
  keda_http_enabled = local.eks.keda_http_enabled

  fargate_enabled   = local.eks.fargate_enabled
  fargate_namespace = local.eks.fargate_namespace

  depends_on = [
    module.vpc,
    module.vpc.public_rtb,
    module.vpc.private_rtb1,
    module.vpc.private_rtb2,
    module.vpc.private_subnet1,
    module.vpc.private_subnet2,
  ]
}

module "vpn" {
  source = "./vpn"

  count = local.vpn.enabled ? 1 : 0

  region                  = local.region
  project                 = local.project
  vpc_id                  = module.vpc.id
  vpc_cidr                = local.vpc.cidr
  gateway_type            = local.vpn.gateway_type
  transit_subnet_ids      = [module.vpc.private_subnet1.id, module.vpc.private_subnet2.id]
  customer_gateway_ip     = local.vpn.customer_gateway_ip
  private_route_table_ids = [module.vpc.private_rtb1.id, module.vpc.private_rtb2.id]
  local_ipv4_cidr         = local.vpn.local_ipv4_cidr
  tunnel1_inside_cidr     = local.vpn.tunnel1_inside_cidr
  tunnel2_inside_cidr     = local.vpn.tunnel2_inside_cidr
  tunnel1_preshared_key   = local.vpn.tunnel1_preshared_key
  tunnel2_preshared_key   = local.vpn.tunnel2_preshared_key

  depends_on = [
    module.vpc
  ]
}

module "rds" {
  source = "./rds"

  count = local.postgres.enabled ? 1 : 0

  vpc_id                = module.vpc.id
  postgres_version      = local.postgres.version
  instance_type         = local.postgres.instance_type
  subnet_ids            = local.postgres.subnet_ids
  multi_az              = local.postgres.multi_az
  initial_db            = local.postgres.initial_db
  username              = local.postgres.username
  password              = local.postgres.password

  create_vpn_rule       = local.vpn.enabled
  vpn_local_ipv4_cidr   = local.vpn.local_ipv4_cidr
  create_eks_rule       = true
  eks_security_group_id = module.eks[0].cluster_security_group_id

  depends_on = [
    module.vpc.database_subnet1,
    module.vpc.database_subnet2
  ]
}

module "amq" {
  source = "./amq"

  count = local.rabbitmq.enabled ? 1 : 0

  vpc_id                = module.vpc.id
  broker_name           = local.rabbitmq.broker_name
  rabbitmq_version      = local.rabbitmq.version
  instance_type         = local.rabbitmq.instance_type
  mode                  = local.rabbitmq.mode
  subnet_ids            = local.rabbitmq.subnet_ids

  username              = local.rabbitmq.username
  password              = local.rabbitmq.password
  create_vpn_rule       = local.vpn.enabled
  vpn_local_ipv4_cidr   = local.vpn.local_ipv4_cidr
  create_eks_rule       = true
  eks_security_group_id = module.eks[0].cluster_security_group_id

  depends_on = [
    module.vpc.private_subnet1,
    module.vpc.private_subnet2
  ]
}

module "cache" {
  source = "./cache"

  count = local.cache.enabled ? 1 : 0

  vpc_id                = module.vpc.id
  instance_type         = local.cache.instance_type
  subnet_ids            = local.cache.subnet_ids
  cluster_name          = local.cache.cluster_name
  engine                = local.cache.engine
  engine_version        = local.cache.version

  auth_type             = local.cache.auth_type
  password              = local.cache.password

  cluster_enabled       = local.cache.cluster_enabled
  nodes_and_replicas    = local.cache.nodes_and_replicas
  multi_az              = local.cache.multi_az

  create_vpn_rule       = local.vpn.enabled
  vpn_local_ipv4_cidr   = local.vpn.local_ipv4_cidr
  create_eks_rule       = true
  eks_security_group_id = module.eks[0].cluster_security_group_id

  depends_on = [
    module.vpc.private_subnet1,
    module.vpc.private_subnet2
  ]
}