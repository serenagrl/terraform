locals {
  region     = "ap-southeast-3"
  project    = "ack"
  access_key = "<Your-Account-Access-Key>"
  secret_key = "<Your-Account-Secret-Key>"

  # Disable this if you are a RAM user and have more than 1 ACK cluster in your account.
  create_roles = true

  ### VPC Settings ###
  vpc = {
    cidr = "10.0.0.0/16"

    vswitch_cidrs = {
      public  = ["10.0.16.0/20", "10.0.32.0/20"]
      private = ["10.0.64.0/20", "10.0.80.0/20"]
      pod     = ["10.0.112.0/20", "10.0.128.0/20"]
    }
  }

  vpn = {
    enabled      = true
    create_roles = false

    # Set your public IP address or null to auto-acquire.
    customer_gateway_ip = null
    on_premise_cidr     = ["192.168.0.0/24"]

    tunnel1_inside_cidr = "169.254.100.0/30"
    tunnel2_inside_cidr = "169.254.101.0/30"

    # Set your keys or null to auto-generate.
    tunnel1_preshared_key = null
    tunnel2_preshared_key = null
  }

  ack = {
    enabled        = true
    create_roles   = true
    cluster_spec   = "ack.pro.small"
    version        = "1.32.1-aliyun.1"
    service_cidr   = "192.168.0.0/16"
    instance_types = ["ecs.g7.xlarge"] # "ecs.u1-c1m2.xlarge" "ecs.u1-c1m1.2xlarge"
    disk_category  = "cloud_essd"
    disk_size      = 40

    # Valid values are "default" or "karpenter"
    autoscaler_type = "karpenter"
    desired_nodes   = 2
    min_count       = 2
    max_count       = 5

    argocd_enabled                = true
    telemetry_enabled             = true
    csi_recycle_bin_enabled       = false
    csi_recycle_bin_reserved_days = 7
  }

  # NOTE: Container Registry Enterprise Edition is Subscription-based and cannot be properly managed by terraform.
  #       Therefore, please manually create the ACR first before enabling this.
  # WARNING: Container Registry Personal Edition is NOT supported.
  acr = {
    configure     = false
    service_cidr  = "10.0.0.0/24"
    registry_name = "ack-registry"
  }

  # NOTE: You need to manually remove the instance from ApsaraDB Postgres Recycle Bin.
  postgres = {
    enabled          = true
    create_roles     = true
    version          = "17.0"
    instance_storage = "10"

    # https://www.alibabacloud.com/help/en/rds/apsaradb-rds-for-postgresql/primary-apsaradb-rds-for-postgresql-instance-types
    # 1m suffix represent single node (eg: pg.n2.2c.1m)
    # 2m suffix represent high availability (1 primary, 1 standby) (eg: pg.n4.2c.2m)
    # xc suffix represent cluster (1 primary, 1 read replica) (eg: pg.n2.2c.xc)
    cluster_enabled  = true
    instance_type    = "pg.n2.2c.1m"
    vswitch_cidrs    = ["10.0.160.0/20", "10.0.176.0/20"]

    # You will not be able to run terraform destroy if you have databases that uses this account.
    username         = "postgres"
    password         = null # Set to null to auto-generate.
  }

  # NOTE: You need to manually remove the RabbitMQ instance from ApsaraMQ. The terraform provider does not remove
  #       it when running terraform destroy.
  rabbitmq = {
    enabled       = true

    # NOTE: Recommended to leave this to false and then manually agree to add the roles from the Portal.
    # WARNING: Roles cannot be removed when 'terraform destroy' because the provider does not remove the rabbitmq instance.
    # You need to delete the rabbitmq instance from portal and then rerun 'terraform destroy' again.
    create_roles  = false

    instance_name = "${local.project}-rabbitmq"
    access_key    = local.access_key
    secret_key    = local.secret_key
  }

  # NOTE: You need to manually remove the instance from Tair Redis Recycle Bin.
  redis = {
    enabled           = true
    engine_version    = "7.0"
    instance_name     = "${local.project}-redis-cache"
    password          = null

    # NOTE: Instance class affects specs and h/a capabilities.
    # https://www.alibabacloud.com/help/en/redis/product-overview/instance-types-of-cloud-native-community-edition-instances
    # Examples:
    #   Standalone: redis.shard.micro.ce
    #   H/A Cluster (direct connection): redis.shard.small.ce
    #   H/A Cluster (proxy connection): redis.shard.with.proxy.small.ce
    instance_class    = "redis.shard.micro.ce"
    high_availability = true
    shard_count       = 1 # set to 2 for H/A Cluster
  }
}