variable "aws" {
  type = "map"
}

variable "cluster-domain" {}

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

variable "dns-service-ip" {}
variable "node-autoscaling-group-name" {}

output "depends-id" {
  value = "${template_dir.manifest.id}"
}
