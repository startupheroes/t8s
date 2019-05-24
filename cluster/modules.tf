module "ami" {
  source = "./ami"
}

module "tls" {
  source = "./tls"
}

module "iv" {
  source = "./intermediate-variables"

  # variables
  cluster            = var.cluster
  master-cidr-offset = var.master-cidr-offset
  master-count       = var.master-count
  subnet-ids-private = var.subnet-ids-private
  cluster-root-tld   = var.cluster-root-tld
}

module "s3" {
  source = "./s3"

  # variables
  aws     = var.aws
  cluster = module.iv.extended-cluster
}

module "route53" {
  source = "./route53"

  # variables
  depends-id   = var.depends-id
  master-count = var.master-count
  vpc-id       = var.vpc-id

  # modules
  cluster    = module.iv.extended-cluster
  master-ips = module.iv.master-ips
}

module "security" {
  source = "./security"

  # variables
  cidr-vpc                      = var.cidr["vpc"]
  cidr-allow-ssh                = var.cidr["allow-ssh"]
  cluster                       = module.iv.extended-cluster
  additional-cidr-blocks-master = var.additional-cidr-blocks-master
  additional-cidr-blocks-node   = var.additional-cidr-blocks-node

  # modules
  vpc-id = var.vpc-id
}

module "iam" {
  source = "./iam"

  # modules
  cluster       = module.iv.extended-cluster
  s3-bucket-arn = module.s3.bucket-arn
}

module "bastion" {
  source     = "./bastion"
  depends-id = var.vpc-id

  # variables
  etcd-version  = var.t8s-version["etcd"]
  instance-type = var.instance-type["bastion"]
  key-name      = var.aws["key-name"]
  timezone      = var.timezone
  vpc-id        = var.vpc-id

  # modules
  ami-id                       = module.ami.ami_id
  cluster                      = module.iv.extended-cluster
  tls-ca-private-key-algorithm = module.tls.tls-ca-private-key-algorithm
  tls-ca-private-key-pem       = module.tls.tls-ca-private-key-pem
  tls-ca-self-signed-cert-pem  = module.tls.tls-self-signed-cert-pem
  security-group-id            = module.security.bastion-id
  subnet-id                    = element(split(",", var.subnet-ids-public), 0)
}

module "master" {
  source = "./master"

  # variables
  vpc-id                    = var.vpc-id
  aws                       = var.aws
  cluster-domain            = var.cluster-domain
  dns-service-ip            = var.dns-service-ip
  depends-id                = var.vpc-id
  enable-api-batch-v2alpha1 = var.enable-api-batch-v2alpha1
  etcd-version              = var.t8s-version["etcd"]
  etcd-storage-backend      = var.etcd-storage-backend
  instance-type             = var.instance-type["master"]
  ip-k8s-service            = var.k8s-service-ip
  k8s                       = var.k8s
  master-count              = var.master-count
  pod-ip-range              = var.cidr["pods"]
  service-cluster-ip-range  = var.cidr["service-cluster"]
  subnet-id-private         = element(split(",", var.subnet-ids-private), 0)
  subnet-id-public          = element(split(",", var.subnet-ids-public), 0)
  timezone                  = var.timezone

  # modules
  ami-id                         = module.ami.ami_id
  cluster                        = module.iv.extended-cluster
  etcd-security-group-id         = module.security.master-id
  external-elb-security-group-id = module.security.external-elb-id
  instance-profile-name          = module.iam.instance-profile-name-master
  master-ips                     = module.iv.master-ips
  s3-bucket                      = module.s3.bucket
  tls-ca-private-key-algorithm   = module.tls.tls-ca-private-key-algorithm
  tls-ca-private-key-pem         = module.tls.tls-ca-private-key-pem
  tls-ca-self-signed-cert-pem    = module.tls.tls-self-signed-cert-pem
}

module "node" {
  source = "./node"

  # variables
  aws            = var.aws
  capacity       = var.capacity
  cluster-domain = var.cluster-domain
  dns-service-ip = var.dns-service-ip
  etcd-version   = var.t8s-version["etcd"]
  instance-type  = var.instance-type["node"]
  k8s            = var.k8s
  node-name      = "general"
  subnet-ids     = var.subnet-ids-private
  volume_size    = var.volume-size
  vpc-id         = var.vpc-id
  timezone       = var.timezone

  # modules
  ami-id                       = module.ami.ami_id
  cluster                      = module.iv.extended-cluster
  instance-profile-name        = module.iam.instance-profile-name-node
  security-group-id            = module.security.node-id
  s3-bucket                    = module.s3.bucket
  tls-ca-private-key-algorithm = module.tls.tls-ca-private-key-algorithm
  tls-ca-private-key-pem       = module.tls.tls-ca-private-key-pem
  tls-ca-self-signed-cert-pem  = module.tls.tls-self-signed-cert-pem
}

module "k8s" {
  source = "./kubeconfig"

  # modules
  cluster                      = module.iv.extended-cluster
  depends-id                   = module.manifest.depends-id
  external-elb                 = module.master.external-elb
  tls-ca-private-key-algorithm = module.tls.tls-ca-private-key-algorithm
  tls-ca-private-key-pem       = module.tls.tls-ca-private-key-pem
  tls-ca-self-signed-cert-pem  = module.tls.tls-self-signed-cert-pem
}

module "manifest" {
  source = "./manifest"

  # variables
  aws            = var.aws
  cluster-domain = var.cluster-domain
  dns-service-ip = var.dns-service-ip

  # module vars
  cluster                     = module.iv.extended-cluster
  node-autoscaling-group-name = module.node.autoscaling-group-name
}

