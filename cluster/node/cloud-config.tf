data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    ca-pem          = "${base64encode(var.tls-ca-self-signed-cert-pem)}"
    cluster-domain  = "${ var.cluster-domain }"
    dns-service-ip  = "${ var.dns-service-ip }"
    hyperkube-image = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag   = "${ var.k8s["hyperkube-tag"] }"
    internal-tld    = "${ var.internal-tld }"
    s3-bucket       = "${ var.s3-bucket }"
    region          = "${ var.aws["region"] }"
    node-key        = "${base64encode(tls_private_key.node.private_key_pem)}"
    node-pem        = "${base64encode(tls_locally_signed_cert.node.cert_pem)}"
  }
}

data "template_file" "cloud-config-fetcher" {
  template = "${ file( "${ path.module }/cloud-config-fetcher.yml" )}"

  vars {
    s3-bucket          = "${ var.s3-bucket }"
    s3-cloud-init-file = "${ format("%s-cloud-config.yml", var.s3-bucket-node-prefix) }"
  }
}

resource "aws_s3_bucket_object" "cloud-config" {
  bucket  = "${ var.s3-bucket }"
  key     = "${format("%s-cloud-config.yml", var.s3-bucket-node-prefix)}"
  content = "${ data.template_file.cloud-config.rendered }"
  etag    = "${ md5(data.template_file.cloud-config.rendered) }"
}
