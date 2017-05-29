# t8s: True Kubernetes Simple Terraform Module

This repo contains [Terraform](https://terraform.io) modules to provision Kubernetes clusters on AWS using [Container Linux by CoreOS](https://coreos.com) (any channel).

Consider this project as beta quality. Configuration in this repository initially was based on awesome [Tack Project](https://github.com/kz8s/tack/), but eventually turned something different. 

## Target of the project
 
 - Supporting multiple clusters on a single VPC
 - Removing makefiles which are available on most projects
 - Easy configuration
 - Eliminate `cfssl`, `ssl`, `bash scripts` and other native binaries
 - Provide immutable architecture: Instead of upgrading cluster, create a new one.

## Included Modules and Modules Layout

Project is including some other modules along with cluster.

1. An optional `ssh-key` generating module. You can use your keys as well. 
2. An optional VPC creating module. It is called `platform` in our codes. 
This is not required but we are recommending to use it since it is ready.
3. A cluster module which is responsible to create cluster.

## Usage

Creating platform and cluster together. 

```bash
provider "aws" {
  region = "${ var.aws["region"] }"
}

module "platform" {
  source                   = "../t8s/platform"

  # variables
  aws                      = "${var.aws}"
  cidr-vpc                 = "${var.cidr["vpc"]}"
  name                     = "${var.name}"
  ssh-public-file          = "${file(var.keypair["public-file"])}"
}

module "cluster-v2" {
  source             = "../t8s/cluster"

  # variables
  aws                = "${var.aws}"
  cidr               = "${var.cidr}"
  internal-tld       = "${var.cluster-v2["internal-tld"]}"
  name               = "${var.cluster-v2["cluster-name"]}"

  # modules
  depends-id         = "${module.platform.depends-id}"
  subnet-ids-private = "${module.platform.subnet-ids-private}"
  subnet-ids-public  = "${module.platform.subnet-ids-public}"
  vpc-id             = "${module.platform.vpc-id}"
}

# variables


variable "name" {
  default = "startupheroes"
}

variable "aws" {
  type = "map"

  default = {
    account-id = "9999999999999"
    azs        = "eu-west-1a,eu-west-1b"
    key-name   = "hero8s-test"
    region     = "eu-west-1"
  }
}

variable "cidr" {
  type = "map"

  default = {
    vpc             = "192.168.0.0/16"
    allow-ssh       = "0.0.0.0/0"
    pods            = "10.2.0.0/16"
    service-cluster = "10.3.0.0/24"
  }
}

variable "keypair" {
  type = "map"

  default = {
    private-file = ".keypair/heroes"
    public-file  = ".keypair/heroes.pub"
  }
}

variable "cluster-v2" {
  type = "map"

  default = {
    internal-tld = "v2.internal.startuphero.es"
    cluster-name = "v2-startuphero"
  }
}

output "platform" {
  value = "${ module.platform.platform }"
}

output "cluster-v2" {
  value = "${ module.cluster-v2.cluster}"
}

```
