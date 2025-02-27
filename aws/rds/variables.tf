variable "vpc_id" {
  type        = string
  description = "The Id of the VPC to host the service."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Id of the Subnets that host the service."
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

variable "postgres_version" {
  type        = string
  default     = "17.2"
  description = "The versiob of postgres."
}

variable "instance_type" {
  type        = string
  default     = "db.t4g.micro"
  description = "The instance type."
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Indicates whether to support multi availability zones."
}

variable "initial_db" {
  type        = string
  description = "The name of the initial database."
}

variable "username" {
  type        = string
  default     = "postgres"
  description = "The default username."
}

variable "password" {
  type        = string
  default     = ""
  description = "The default password. (Leave blank to auto-generate)."
}