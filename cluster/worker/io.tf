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

variable "instance-profile-name" {}
variable "instance-type" {}
variable "internal-tld" {}

variable "k8s" {
  type = "map"
}

variable "name" {}
variable "s3-bucket" {}

variable "s3-bucket-worker-prefix" {
  description = "Cloud init file prefix in s3 bucket"
  default     = "worker-cloud-init"
}

variable "security-group-id" {}
variable "subnet-id" {}

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
variable "worker-name" {}

output "autoscaling-group-name" {
  value = "${ aws_autoscaling_group.worker.name }"
}

output "depends-id" {
  value = "${ null_resource.dummy_dependency.id }"
}
