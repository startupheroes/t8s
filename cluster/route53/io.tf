variable "depends-id" {}
variable "master-count" {}
variable "master-ips" {}
variable "vpc-id" {}

variable "cluster" {
  type = "map"

  default = {
    name             = ""
    version          = ""
    cluster-id       = ""
    cluster-tld      = ""
    cluster-root-tld = ""
  }
}

output "depends-id" {
  value = "${null_resource.dummy_dependency.id}"
}

output "internal-name-servers" {
  value = "${ aws_route53_zone.internal.name_servers }"
}

output "cluster-internal-zone-id" {
  value = "${ aws_route53_zone.internal.zone_id }"
}
