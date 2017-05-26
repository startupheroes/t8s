variable "master-cidr-offset" {}
variable "master-count" {}
variable "subnet-ids-private" {}

output "master-ips" {
  value = "${join(",", null_resource.master.*.triggers.ip)}"
}
