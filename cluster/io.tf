variable "name" {}
variable "internal-tld" {}

variable "cluster-domain" {
  default = "cluster.local"
}


variable "master-count" {
  default = "3"
}

variable "master-cidr-offset" {
  default = "10"
}

variable "dns-service-ip" {
  default = "10.3.0.10"
}

variable "k8s-service-ip" {
  default = "10.3.0.1"
}

variable "vpc-id" {}
variable "subnet-ids-public" {}
variable "subnet-ids-private" {}
variable "internal-zone-id" {}

variable "k8s" {
  type = "map"

  default = {
    hyperkube-image = "quay.io/coreos/hyperkube"
    hyperkube-tag   = "v1.6.2_coreos.0"
  }
}

variable "cidr" {
  type = "map"

  default = {
    vpc             = "10.0.0.0/16"
    allow-ssh       = "0.0.0.0/0"
    pods            = "10.2.0.0/16"
    service-cluster = "10.3.0.0/24"
  }
}

variable "instance-type" {
  type = "map"

  default = {
    bastion = "t2.nano"
    etcd    = "m3.large"
    worker  = "m3.large"
  }
}

variable "coreos-aws" {
  type = "map"

  default = {
    ami = "ami-0bcbcb6d"
  }
}

variable "aws" {
  type = "map"

  default = {
    account-id = ""
    azs        = ""
    key-name   = ""
    region     = ""
  }
}

# outputs
output "cluster-domain" {
  value = "${ var.cluster-domain }"
}

output "dns-service-ip" {
  value = "${ var.dns-service-ip }"
}

output "master1-ip" {
  value = "${ element( split(",", module.vpc.master-ips), 0 ) }"
}

output "bastion-ip" {
  value = "${ module.bastion.ip }"
}

output "external-elb" {
  value = "${ module.master.external-elb }"
}

output "internal-tld" {
  value = "${ var.internal-tld }"
}

output "worker-autoscaling-group-name" {
  value = "${ module.worker.autoscaling-group-name }"
}

output "cluster-ips" {
  value = "${
    map(
      "bastion", "${ module.bastion.ip }",
      "dns-service", "${ var.dns-service-ip }",
      "etcd", "${ module.vpc.master-ips }"
    )
  }"
}
