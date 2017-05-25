provider "aws" {
  region = "${ var.aws["region"] }"
}

module "vpc" {
  source = "vpc"

  # variables
  master-cidr-offset = "${ var.master-cidr-offset }"
  master-count       = "${var.master-count}"
  subnet-ids-private = "${ var.subnet-ids-private}"
}

module "s3" {
  source = "s3"

  # variables
  aws    = "${ var.aws }"
  bucket = "t8s-cloud-init-${ var.name }-${ var.aws["account-id"] }-${ var.aws["region"] }"
  name   = "${ var.name }"
}

module "tls" {
  source = "tls"
}

module "route53" {
  source = "route53"

  # variables
  master-ips   = "${ module.vpc.master-ips }"
  internal-tld = "${ var.internal-tld }"

  # modules
  internal-zone-id = "${var.internal-zone-id}"
  master-count     = "${ var.master-count }"
}

module "security" {
  source = "security"

  # variables
  cidr-vpc       = "${ var.cidr["vpc"] }"
  cidr-allow-ssh = "${ var.cidr["allow-ssh"] }"
  name           = "${ var.name }"

  # modules
  vpc-id = "${ var.vpc-id }"
}

module "iam" {
  source = "iam"

  # variables
  name = "${ var.name }"

  # modules
  s3-bucket-arn = "${ module.s3.bucket-arn }"
}

module "bastion" {
  source     = "bastion"
  depends-id = "${ var.vpc-id }"

  # variables
  ami-id        = "${ var.coreos-aws["ami"] }"
  instance-type = "${ var.instance-type["bastion"] }"
  internal-tld  = "${ var.internal-tld }"
  key-name      = "${ var.aws["key-name"] }"
  name          = "${ var.name }"

  # modules
  security-group-id = "${ module.security.bastion-id }"
  subnet-id         = "${ element( split(",", var.subnet-ids-public), 0 ) }"
  vpc-id            = "${ var.vpc-id }"
}

module "master" {
  source = "master"

  # variables
  vpc-id                   = "${ var.vpc-id }"
  ami-id                   = "${ var.coreos-aws["ami"] }"
  aws                      = "${ var.aws }"
  cluster-domain           = "${ var.cluster-domain }"
  dns-service-ip           = "${ var.dns-service-ip }"
  instance-type            = "${ var.instance-type["etcd"] }"
  internal-tld             = "${ var.internal-tld }"
  ip-k8s-service           = "${ var.k8s-service-ip }"
  k8s                      = "${ var.k8s }"
  name                     = "${ var.name }"
  pod-ip-range             = "${ var.cidr["pods"] }"
  service-cluster-ip-range = "${ var.cidr["service-cluster"] }"
  subnet-id-private        = "${ element( split(",", var.subnet-ids-private), 0 ) }"
  subnet-id-public         = "${ element( split(",", var.subnet-ids-public), 0 ) }"

  # modules
  etcd-security-group-id         = "${ module.security.master-id }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  instance-profile-name          = "${ module.iam.instance-profile-name-master }"
  master-ips                     = "${ module.vpc.master-ips }"
  master-count                   = "${ var.master-count }"
  s3-bucket                      = "${ module.s3.bucket }"
  tls-ca-private-key-algorithm   = "${ module.tls.tls-ca-private-key-algorithm }"
  tls-ca-private-key-pem         = "${ module.tls.tls-ca-private-key-pem }"
  tls-ca-self-signed-cert-pem    = "${ module.tls.tls-self-signed-cert-pem }"
}

module "worker" {
  source = "worker"

  # variables
  ami-id = "${ var.coreos-aws["ami"] }"
  aws    = "${ var.aws }"

  capacity = {
    desired = 1
    max     = 5
    min     = 1
  }

  cluster-domain = "${ var.cluster-domain }"
  dns-service-ip = "${ var.dns-service-ip }"
  instance-type  = "${ var.instance-type["worker"] }"
  internal-tld   = "${ var.internal-tld }"
  k8s            = "${ var.k8s }"
  name           = "${ var.name }"

  volume_size = {
    ebs  = 250
    root = 52
  }

  worker-name = "general"

  # modules
  instance-profile-name        = "${ module.iam.instance-profile-name-worker }"
  security-group-id            = "${ module.security.worker-id }"
  subnet-id                    = "${ element( split(",", var.subnet-ids-private), 0 ) }"
  vpc-id                       = "${ var.vpc-id }"
  s3-bucket                    = "${ module.s3.bucket }"
  tls-ca-private-key-algorithm = "${module.tls.tls-ca-private-key-algorithm}"
  tls-ca-private-key-pem       = "${module.tls.tls-ca-private-key-pem}"
  tls-ca-self-signed-cert-pem  = "${module.tls.tls-self-signed-cert-pem}"
}

module "k8s" {
  source = "kubernetes"

  # variables
  cluster-name = "${ var.name }"

  # modules
  external-elb                 = "${module.master.external-elb}"
  tls-ca-private-key-algorithm = "${module.tls.tls-ca-private-key-algorithm}"
  tls-ca-private-key-pem       = "${module.tls.tls-ca-private-key-pem}"
  tls-ca-self-signed-cert-pem  = "${module.tls.tls-self-signed-cert-pem}"
}
