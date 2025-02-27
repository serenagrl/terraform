variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "The AWS region to create this VPN in."
}

variable "project" {
  type        = string
  default     = "terraform"
  description = "The name of the project."
}

variable "vpc_id" {
  type        = string
  description = "The Id of the VPC."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR of the VPC."
}

variable "customer_gateway_ip" {
  type        = string
  default     = ""
  description = "The public IP of the customer gateway. (Leave blank to auto curl for it)."
}

variable "gateway_type" {
  type        = string
  default     = "virtual_private"
  description = "The gateway type."

  validation {
    condition     = upper(var.gateway_type) == "VIRTUAL_PRIVATE" || upper(var.gateway_type) == "TRANSIT"
    error_message = "Supported gateway types are either \"virtual_private\" or \"transit\""
  }
}

variable "transit_subnet_ids" {
  type        = list(string)
  description = "The Subnet Ids for the transit gateway."

  validation {
    condition     = upper(var.gateway_type) == "TRANSIT" ? length(var.transit_subnet_ids) > 0 : true
    error_message = "Subnet Ids must be provided when creating transit gateways."
  }
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "The private route table Ids."
}

variable "local_ipv4_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "The local on-premise CIDR."
}

variable "tunnel1_inside_cidr" {
  type        = string
  default     = "169.254.100.0/30"
  description = "The CIDR for the first inside tunnel."
}

variable "tunnel2_inside_cidr" {
  type        = string
  default     = "169.254.101.0/30"
  description = "The CIDR for the second inside tunnel."
}

variable "tunnel1_preshared_key" {
  type = string
  default = null
  description = "The preshared key for the first inside tunnel. (Leave blank to auto generate)."
}

variable "tunnel2_preshared_key" {
  type = string
  default = null
  description = "The preshared key for the second inside tunnel. (Leave blank to auto generate)."
}