variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "The AWS region to create this VPC in."
}

variable "project" {
  type        = string
  default     = "terraform"
  description = "The name of the project."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR to use for the VPC."
}

variable "subnet_cidrs" {
  type = object({
    public   = list(string)
    private  = list(string)
  })

  description = "The Subnets to create in the VPC."
}