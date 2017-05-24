variable "internal-tld" {}
variable "etcd-ips" {}
variable "internal-zone-id" {}

output "depends-id" {
  value = "${null_resource.dummy_dependency.id}"
}
