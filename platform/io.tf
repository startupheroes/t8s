variable "aws" {
  type = map(string)
}

variable "name" {
}

variable "cidr-vpc" {
}

variable "ssh-public-file" {
}

variable "cidr-step-private-subnet" {
  default = "10"
}

variable "cidr-offset-subnet" {
  default = "0"
}

variable "cidr-newbits" {
  default = "8"
}

variable "propagating-vgws-private" {
  default = ""
}

# outputs
output "azs" {
  value = var.aws["azs"]
}

output "depends-id" {
  value = module.vpc.depends-id
}

output "vpc-id" {
  value = module.vpc.id
}

output "name" {
  value = var.name
}

output "region" {
  value = var.aws["region"]
}

output "subnet-ids-private" {
  value = module.vpc.subnet-ids-private
}

output "subnet-ids-private-cidr" {
  value = module.vpc.subnet-ids-private-cidr
}

output "subnet-ids-public" {
  value = module.vpc.subnet-ids-public
}

output "subnet-ids-public-cidr" {
  value = module.vpc.subnet-ids-public-cidr
}

output "platform" {
  value = {
    "azs"                     = var.aws["azs"]
    "depends-id"              = module.vpc.depends-id
    "name"                    = var.name
    "region"                  = var.aws["region"]
    "subnet-ids-private"      = module.vpc.subnet-ids-private
    "subnet-ids-public"       = module.vpc.subnet-ids-public
    "subnet-ids-private-cidr" = module.vpc.subnet-ids-private-cidr
    "subnet-ids-public-cidr"  = module.vpc.subnet-ids-public-cidr
    "vpc-id"                  = module.vpc.id
    "nat-gateway-ip"          = module.vpc.nat-gateway-ip
  }
}

