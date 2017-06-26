variable "cidr-allow-ssh" {}
variable "cidr-vpc" {}

variable "cluster" {
  type = "map"

  default = {
    name              = ""
    version           = ""
    cluster-id        = ""
    cluster-tld      = ""
    cluster-root-tld = ""
  }
}

variable "vpc-id" {}

variable "additional-cidr-blocks-master" {}

variable "additional-cidr-blocks-node" {}

output "depends-id" {
  value = "${ null_resource.dummy_dependency.id }"
}

output "bastion-id" {
  value = "${ aws_security_group.bastion.id }"
}

output "master-id" {
  value = "${ aws_security_group.master.id }"
}

output "external-elb-id" {
  value = "${ aws_security_group.external-elb.id }"
}

output "node-id" {
  value = "${ aws_security_group.node.id }"
}
