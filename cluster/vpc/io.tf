variable "master-cidr-offset" {}
variable "master-count" {}
variable "subnet-ids-private" {}

output "master-ips" {
  value = "${join(",", data.template_file.master.*.rendered)}"
}
