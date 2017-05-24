resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_cert_request" "admin" {
  key_algorithm   = "${tls_private_key.admin.algorithm}"
  private_key_pem = "${tls_private_key.admin.private_key_pem}"

  subject {
    common_name = "kube-admin"
  }
}

resource "tls_locally_signed_cert" "admin" {
  cert_request_pem      = "${tls_cert_request.admin.cert_request_pem}"
  ca_key_algorithm      = "${var.tls-ca-private-key-algorithm}"
  ca_private_key_pem    = "${var.tls-ca-private-key-pem}"
  ca_cert_pem           = "${var.tls-ca-self-signed-cert-pem}"
  validity_period_hours = 8760
  allowed_uses          = []

  lifecycle {
    create_before_destroy = true
  }
}
