# this is the name given to the vpc created by this module
variable "vpc_name" {
  default = "terraform_vpc"
  type    = string
}

# This is the cidr range that the VPC is created with
variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type    = string
}

# These are the public subnets that will be created for this moduls
variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type    = list(string)
}

# these are the private subnets that will be crated for this module
variable "private_subnets" {
  default = []
  type    = list(string)
}

# this is the credential profile to use when provisioning resources
variable "profile" {
  default = "default"
  type    = string
}

variable "region" {
  default = "us-east-1"
  type    = string
}


variable "public_ssh_key" {
  type = string
}


