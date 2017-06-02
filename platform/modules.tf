module "ssh" {
  source = "ssh"

  # variable
  name = "${ var.aws["key-name"] }"

  public-file = "${var.ssh-public-file}"
}

module "vpc" {
  source     = "vpc"
  depends-id = ""

  # variables
  azs                      = "${ var.aws["azs"] }"
  cidr                     = "${ var.cidr-vpc }"
  cidr-newbits             = "${ var.cidr-newbits}"
  cidr-offset-subnet       = "${ var.cidr-offset-subnet}"
  cidr-step-private-subnet = "${ var.cidr-step-private-subnet}"
  name                     = "${ var.name }"
  region                   = "${ var.aws["region"] }"
}
