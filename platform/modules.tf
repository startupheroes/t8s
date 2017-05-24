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
  azs    = "${ var.aws["azs"] }"
  cidr   = "${ var.cidr["vpc"] }"
  name   = "${ var.name }"
  region = "${ var.aws["region"] }"
}

module "route53" {
  source     = "route53"
  depends-id = "${ module.vpc.depends-id }"

  # variables
  internal-tld = "${ var.internal-tld }"
  name         = "${ var.name }"

  # modules
  vpc-id = "${ module.vpc.id }"
}
