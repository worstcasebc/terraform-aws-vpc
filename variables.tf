variable "name" {
  type        = string
  description = "Name of the VPC"
  default     = "MyVPC"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list
  default = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_classiclink" {
  type    = bool
  default = false
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "bastion_host" {
  description = "I a bastion host necessary to connect to resources in private networks by SSH?"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the KeyPair for ssh-access"
  type = string
  default = "mbp"
}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}