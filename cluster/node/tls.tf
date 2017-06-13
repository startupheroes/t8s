resource "tls_private_key" "node" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_cert_request" "node" {
  key_algorithm   = "${tls_private_key.node.algorithm}"
  private_key_pem = "${tls_private_key.node.private_key_pem}"

  subject {
    common_name = "kube-apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "master.${ var.cluster["internal-tld"] }",
    "*.*.compute.internal",
    "*.ec2.internal",
  ]
}

resource "tls_locally_signed_cert" "node" {
  cert_request_pem      = "${tls_cert_request.node.cert_request_pem}"
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
