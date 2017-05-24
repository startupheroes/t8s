resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name = "kube-ca"
  }

  validity_period_hours = 87600

  allowed_uses = []

  early_renewal_hours = 720
  is_ca_certificate   = true

  lifecycle {
    create_before_destroy = true
  }
}
