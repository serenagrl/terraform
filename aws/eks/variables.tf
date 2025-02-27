variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "The AWS region to create this EKS in."
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

variable "subnet_ids" {
  type        = list(string)
  description = "The Id of the Subnets to host the worker nodes."
}

variable "k8s_version" {
  type        = string
  default     = ""
  description = "The kubernetes version. (Leave blank to use latest stable supported version)."
}

variable "ami" {
  type        = string
  default     = "AL2_x86_64"
  description = "The AMI to use for the worker nodes."
}

variable "capacity" {
  type        = string
  default     = "ON_DEMAND"
  description = "The capacity type. (Only suports ON_DEMAND currently)."
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "The instance type."
}

variable "disk_size" {
  type        = number
  default     = 20
  description = "The disk size."
}

variable "desired_nodes" {
  type        = number
  default     = 2
  description = "The desired number of nodes."
}

variable "min_nodes" {
  type        = number
  default     = 2
  description = "The minimum number of nodes required."
}

variable "max_nodes" {
  type        = number
  default     = 6
  description = "The maximum number of nodes allowed."
}

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether to enable fargate profile."
}

variable "fargate_namespace" {
  type        = string
  default     = null
  description = "The namespace for the fargate profile to monitor."

  validation {
    condition     = var.fargate_enabled ? (var.fargate_namespace != null && var.fargate_namespace != "") : true
    error_message = "A default fargate namespace must be specified when fargate is enabled."
  }

}

variable "autoscaler_type" {
  type        = string
  default     = "karpenter"
  description = "The type of autoscaler to enable."

  validation {
    condition     = upper(var.autoscaler_type) == "KARPENTER" || upper(var.autoscaler_type) == "CLUSTER" || upper(var.autoscaler_type) == "NONE"
    error_message = "Supported autoscaler types are either \"karpenter\", \"cluster\" or \"none\""
  }
}

variable "keda_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether to enable KEDA."
}

variable "keda_http_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether to enable KEDA HTTP add-on."
}