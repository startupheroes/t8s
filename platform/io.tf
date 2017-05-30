variable "aws" {
  type = "map"
}

variable "name" {}
variable "cidr-vpc" {}
variable "internal-tld" {}
variable "ssh-public-file" {}

variable "cidr-step-private-subnet" {
  default = "10"
}

variable "cidr-offset-subnet" {
  default = "0"
}

# outputs
output "azs" {
  value = "${ var.aws["azs"] }"
}

output "depends-id" {
  value = "${module.vpc.depends-id}"
}

output "vpc-id" {
  value = "${ module.vpc.id}"
}

output "name" {
  value = "${ var.name }"
}

output "region" {
  value = "${ var.aws["region"] }"
}

output "subnet-ids-private" {
  value = "${ module.vpc.subnet-ids-private }"
}

output "subnet-ids-public" {
  value = "${ module.vpc.subnet-ids-public }"
}
