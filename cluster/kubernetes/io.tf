variable "cluster-name" {}
variable "external-elb" {}

variable "tls-ca-private-key-algorithm" {}
variable "tls-ca-private-key-pem" {}
variable "tls-ca-self-signed-cert-pem" {}

variable "admin-file" {
  default = "k8s-admin.pem"
}

variable "admin-key-file" {
  default = "k8s-admin-key.pem"
}

variable "ca-file" {
  default = "ca.pem"
}

variable "dir-ssl" {
  default = ".cfssl"
}
