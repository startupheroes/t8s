variable "master-cidr-offset" {}
variable "master-count" {}
variable "subnet-ids-private" {}
variable "cluster-root-tld" {}

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
              "cluster-tld", format("%sv%s.%s", var.cluster["name"], replace( var.cluster["version"],  "/[[:^alnum:]]/", ""), var.cluster-root-tld),
              "cluster-root-tld", var.cluster-root-tld
           )}"
}

output "master-ips" {
  value = "${join(",", null_resource.master.*.triggers.ip)}"
}
