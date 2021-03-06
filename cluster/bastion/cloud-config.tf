data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars =  {
    cluster-tld  = "${ var.cluster["cluster-tld"] }"
    ca-pem       = "${base64encode(var.tls-ca-self-signed-cert-pem)}"
    bastion-key  = "${base64encode(tls_private_key.bastion.private_key_pem)}"
    bastion-pem  = "${base64encode(tls_locally_signed_cert.bastion.cert_pem)}"
    etcd-version = "${ var.etcd-version }"
    timezone     = "${ var.timezone }"
  }
}
