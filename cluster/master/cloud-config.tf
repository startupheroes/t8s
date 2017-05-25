data "template_file" "cloud-config" {
  count    = "${ var.master-count }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    apiserver-count          = "${ length( split(",", var.master-ips) ) }"
    cluster-domain           = "${ var.cluster-domain }"
    cluster-token            = "etcd-cluster-${ var.name }"
    dns-service-ip           = "${ var.dns-service-ip }"
    external-elb             = "${ aws_elb.external.dns_name }"
    fqdn                     = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname                 = "etcd${ count.index + 1 }"
    hyperkube                = "${ var.k8s["hyperkube-image"] }:${ var.k8s["hyperkube-tag"] }"
    hyperkube-image          = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag            = "${ var.k8s["hyperkube-tag"] }"
    internal-tld             = "${ var.internal-tld }"
    ip-k8s-service           = "${ var.ip-k8s-service }"
    pod-ip-range             = "${ var.pod-ip-range }"
    region                   = "${ var.aws["region"] }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    ca-pem                   = "${base64encode(var.tls-ca-self-signed-cert-pem)}"
    etcd-key                 = "${base64encode(element(tls_private_key.etcd.*.private_key_pem,count.index))}"
    etcd-pem                 = "${base64encode(element(tls_locally_signed_cert.etcd.*.cert_pem,count.index))}"
    apiserver-key            = "${base64encode(element(tls_private_key.apiserver.*.private_key_pem,count.index))}"
    apiserver-pem            = "${base64encode(element(tls_locally_signed_cert.apiserver.*.cert_pem,count.index))}"
    service-account-key      = "${base64encode(tls_private_key.service-account.private_key_pem)}"
  }
}

data "template_file" "cloud-config-fetcher" {
  count    = "${ var.master-count }"
  template = "${ file( "${ path.module }/cloud-config-fetcher.yml" )}"

  vars {
    s3-bucket          = "${ var.s3-bucket }"
    s3-cloud-init-file = "${ format("%s-%d-cloud-config.yml", var.s3-bucket-master-prefix, count.index) }"
  }
}

resource "aws_s3_bucket_object" "cloud-config" {
  count   = "${ var.master-count }"
  bucket  = "${ var.s3-bucket }"
  key     = "${format("%s-%d-cloud-config.yml", var.s3-bucket-master-prefix, count.index)}"
  content = "${ element(data.template_file.cloud-config.*.rendered, count.index) }"
  etag    = "${ md5(element(data.template_file.cloud-config.*.rendered, count.index)) }"
}
