variable "ami-id" {}

variable "aws" {
  type = "map"
}

variable "capacity" {
  type = "map"

  default = {
    desired = 5
    max     = 5
    min     = 3
  }
}

variable "cluster-domain" {}
variable "dns-service-ip" {}

variable "etcd-version" {}
variable "instance-profile-name" {}
variable "instance-type" {}
variable "timezone" {}

variable "k8s" {
  type = "map"
}

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

variable "s3-bucket" {}

variable "s3-bucket-node-prefix" {
  description = "Cloud init file prefix in s3 bucket"
  default     = "node-cloud-init"
}

variable "security-group-id" {}
variable "subnet-ids" {}

variable "volume_size" {
  type = "map"

  default = {
    ebs  = 250
    root = 52
  }
}

variable "tls-ca-private-key-algorithm" {}
variable "tls-ca-private-key-pem" {}
variable "tls-ca-self-signed-cert-pem" {}
variable "vpc-id" {}
variable "node-name" {}

output "autoscaling-group-name" {
  value = "${ aws_autoscaling_group.node.name }"
}

output "autoscaling-group-id" {
  value = "${ aws_autoscaling_group.node.id }"
}

output "depends-id" {
  value = "${ null_resource.dummy_dependency.id }"
}
