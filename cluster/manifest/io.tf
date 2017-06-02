variable "aws" {
  type = "map"
}

variable "cluster-domain" {}
variable "cluster-name" {}
variable "dns-service-ip" {}
variable "internal-tld" {}
variable "node-autoscaling-group-name" {}

output "depends-id" {
  value = "${template_dir.manifest.id}"
}
