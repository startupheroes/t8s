variable "master-cidr-offset" {}
variable "master-count" {}
variable "subnet-ids-private" {}
variable "root-internal-tld" {}

variable "cluster" {
  type = "map"

  default = {
    name    = ""
    version = ""
  }
}

output "extended-cluster" {
  value = "${ map(
              "name", var.cluster["name"],
              "version", var.cluster["version"],
              "cluster-id", format("%s-v%s", var.cluster["name"], replace( var.cluster["version"],  "/[[:^alnum:]]/", "")),
              "internal-tld", format("%sv%s.%s", var.cluster["name"], replace( var.cluster["version"],  "/[[:^alnum:]]/", ""), var.root-internal-tld),
              "root-internal-tld", var.root-internal-tld
           )}"
}

output "master-ips" {
  value = "${join(",", null_resource.master.*.triggers.ip)}"
}
