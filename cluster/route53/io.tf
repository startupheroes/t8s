variable "internal-tld" {}
variable "master-count" {}
variable "master-ips" {}
variable "internal-zone-id" {}

output "depends-id" {
  value = "${null_resource.dummy_dependency.id}"
}
