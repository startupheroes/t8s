resource "aws_route53_zone" "internal" {

  comment = "Kubernetes [t8s] cluster DNS (internal)"
  name    = "${var.cluster["cluster-tld"]}"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_route53_record" "A-etcd" {
  name    = "etcd"
  records = ["${ split(",", var.master-ips) }"]
  ttl     = "300"
  type    = "A"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "A-etcds" {
  count = "${ var.master-count }"

  name = "etcd${ count.index+1 }"
  ttl  = "300"
  type = "A"

  records = [
    "${ element(split(",", var.master-ips), count.index) }",
  ]

  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "CNAME-master" {
  name    = "master"
  records = ["etcd.${ var.cluster["cluster-tld"] }"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name    = "_etcd-client._tcp"
  ttl     = "300"
  type    = "SRV"
  records = ["${ formatlist("0 0 2379 %v", aws_route53_record.A-etcds.*.fqdn) }"]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name    = "_etcd-server-ssl._tcp"
  ttl     = "300"
  type    = "SRV"
  records = ["${ formatlist("0 0 2380 %v", aws_route53_record.A-etcds.*.fqdn) }"]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_route53_record.etcd-server-tcp",
    "aws_route53_record.A-etcd",
  ]
}
