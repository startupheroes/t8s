resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_cert_request" "apiserver" {
  count = "${ var.master-count }"

  key_algorithm   = "${tls_private_key.apiserver.algorithm}"
  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name = "kube-apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "master.${ var.cluster["cluster-tld"] }",
    "${aws_elb.external.dns_name}",
  ]

  ip_addresses = [
    "127.0.0.1",
    "${ var.ip-k8s-service}",
    "${element(split(",", var.master-ips),count.index)}",
  ]
}

resource "tls_locally_signed_cert" "apiserver" {
  count = "${ var.master-count }"

  cert_request_pem      = "${element(tls_cert_request.apiserver.*.cert_request_pem, count.index)}"
  ca_key_algorithm      = "${var.tls-ca-private-key-algorithm}"
  ca_private_key_pem    = "${var.tls-ca-private-key-pem}"
  ca_cert_pem           = "${var.tls-ca-self-signed-cert-pem}"
  validity_period_hours = 43800

  allowed_uses = [
    "any_extended",
    "nonRepudiation",
    "digitalSignature",
    "keyEncipherment",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_private_key" "etcd" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_cert_request" "etcd" {
  count = "${ var.master-count }"

  key_algorithm   = "${tls_private_key.etcd.algorithm}"
  private_key_pem = "${tls_private_key.etcd.private_key_pem}"

  subject {
    common_name = "kube-etcd"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "etcd.${ var.cluster["cluster-tld"] }",
    "etcd${ count.index + 1 }.${ var.cluster["cluster-tld"] }",
  ]

  ip_addresses = [
    "127.0.0.1",
    "${element(split(",", var.master-ips),count.index)}",
  ]
}

resource "tls_locally_signed_cert" "etcd" {
  count = "${ var.master-count }"

  cert_request_pem      = "${element(tls_cert_request.etcd.*.cert_request_pem,count.index)}"
  ca_key_algorithm      = "${var.tls-ca-private-key-algorithm}"
  ca_private_key_pem    = "${var.tls-ca-private-key-pem}"
  ca_cert_pem           = "${var.tls-ca-self-signed-cert-pem}"
  validity_period_hours = 43800

  allowed_uses = [
    "any_extended",
    "nonRepudiation",
    "digitalSignature",
    "keyEncipherment",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_private_key" "service-account" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}
