provider "aws" {
  region = "${ var.aws["region"] }"
}

variable "aws" {
  type = "map"
}

variable "cidr" {
  type = "map"

  default = {
    vpc = "10.0.0.0/16"
  }
}

variable "name" {}
variable "internal-tld" {}
variable "ssh-public-file" {}

# outputs
output "azs" {
  value = "${ var.aws["azs"] }"
}

output "vpc-id" {
  value = "${ module.vpc.id}"
}

output "internal-zone-id" {
  value = "${ module.route53.internal-zone-id}"
}

output "internal-name-servers" {
  value = "${ module.route53.internal-name-servers}"
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
