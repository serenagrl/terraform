variable "vpc_id" {
  type        = string
  description = "The Id of the VPC that host the service."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Id of the Subnets to host the service."
}

variable "create_vpn_rule" {
  type        = bool
  default     = false
  description = "Indicates whether to create ingress rules for VPN."
}

variable "vpn_local_ipv4_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "The local on-premise CIDR for the VPN."
}

variable "create_eks_rule" {
  type        = bool
  default     = false
  description = "Indicates whether to create ingress rules for EKS."
}

variable "eks_security_group_id" {
  type        = string
  description = "The Security Group Id of the EKS."
}

variable "cluster_name" {
  type        = string
  default     = "cache-cluster"
  description = "The name of the cluster."
}

variable "engine" {
  type        = string
  default     = "redis"
  description = "The cache engine to use."

  validation {
    condition     = upper(var.engine) == "REDIS" || upper(var.engine) == "VALKEY"
    error_message = "Supported engines are either \"redis\" or \"valkey\""
  }
}

variable "engine_version" {
  type        = string
  description = "The cache engine version."
}

variable "instance_type" {
  type        = string
  default     = "mq.t3.micro"
  description = "The instance type."
}

variable "auth_type" {
  type = string
  default = "token"
  description = "The type of authentication to use."
  validation {
    condition     = upper(var.auth_type) == "TOKEN" || upper(var.auth_type) == "USER"
    error_message = "Supported authentication types are either \"token\" or \"user\""
  }

}

variable "password" {
  type = string
  default = ""
  description = "The default password. (Leave blank to auto-generate)."
}

variable "cluster_enabled" {
  type = bool
  description = "Indicates whether to enable cluster."
}

variable "nodes_and_replicas" {
  type = list(number)
  description = "The desired number of nodes and replicas for each node."
  validation {
    condition     = length(var.nodes_and_replicas) == 2
    error_message = "Nodes and replicas must be in the format of [nodes, replicas] i.e. [2, 1]."
  }
}

variable "multi_az" {
  type = bool
  description = "Indicates whether to support multi availability zones."
}