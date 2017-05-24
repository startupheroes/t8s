output "tls-ca-private-key-algorithm" {
  value = "${tls_private_key.ca.algorithm}"
}

output "tls-ca-private-key-pem" {
  value = "${tls_private_key.ca.private_key_pem}"
}

output "tls-self-signed-cert-pem" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}
