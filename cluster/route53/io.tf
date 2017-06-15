variable "depends-id" {}
variable "master-count" {}
variable "master-ips" {}
variable "vpc-id" {}

variable "internal-zone-id" {
  default = ""
}

variable "cluster" {
  type = "map"

  default = {
    name              = ""
    version           = ""
    cluster-id        = ""
    internal-tld      = ""
    root-internal-tld = ""
  }
}

output "depends-id" {
  value = "${null_resource.dummy_dependency.id}"
}

output "internal-name-servers" {
  value = "${ aws_route53_zone.internal.name_servers }"
}

output "cluster-internal-zone-id" {
  value = "${ null_resource.interpolated_id.triggers.zone-id }"
}
