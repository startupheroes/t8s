variable "aws" {
  type = "map"
}

variable "name" {}
variable "cidr-vpc" {}
variable "ssh-public-file" {}

variable "cidr-step-private-subnet" {
  default = "10"
}

variable "cidr-offset-subnet" {
  default = "0"
}

variable "cidr-newbits" {
  default = "8"
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

output "platform" {
  value = "${
    map(
      "azs", "${ var.aws["azs"] }",
      "depends-id", "${module.vpc.depends-id}",
      "name", "${var.name}",
      "region", "${var.aws["region"]}",
      "subnet-ids-private", "${ module.vpc.subnet-ids-private }",
      "subnet-ids-public", "${ module.vpc.subnet-ids-public }",
      "vpc-id", "${module.vpc.id}"
    )
  }"
}
