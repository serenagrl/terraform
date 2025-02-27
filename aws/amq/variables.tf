variable "vpc_id" {
  type        = string
  description = "The Security Group Id of the EKS."
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

variable "broker_name" {
  type        = string
  default     = "rabbitmq"
  description = "The name of the broker."
}

variable "rabbitmq_version" {
  type        = string
  description = "The Rabbitmq version."
}

variable "instance_type" {
  type        = string
  default     = "mq.t3.micro"
  description = "The instance type."
}

variable "mode" {
  type        = string
  default     = "SINGLE_INSTANCE"
  description = "The deployment mode."

  validation {
    condition     = upper(var.mode) == "SINGLE_INSTANCE" || upper(var.mode) == "CLUSTER_MULTI_AZ"
    error_message = "Supported modes are either \"SINGLE_INSTANCE\" or \"CLUSTER_MULTI_AZ\""
  }
}

variable "username" {
  type        = string
  default     = "rabbit-admin"
  description = "The default username."
}

variable "password" {
  type = string
  default = ""
  description = "The default password. (Leave blank to auto-generate)."
}