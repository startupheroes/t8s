resource "aws_route53_zone" "internal" {
  count = "${var.internal-zone-id == "" ? 1 : 0}"

  comment = "Kubernetes [t8s] cluster DNS (internal)"
  name    = "${var.cluster["root-internal-tld"]}"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "null_resource" "interpolated_id" {
  triggers {
    zone-id = "${coalesce(var.internal-zone-id,  join("", aws_route53_zone.internal.*.zone_id))}"
  }
}

resource "aws_route53_record" "A-etcd" {
  name    = "etcd.${var.cluster["internal-tld"]}"
  records = ["${ split(",", var.master-ips) }"]
  ttl     = "300"
  type    = "A"
  zone_id = "${ null_resource.interpolated_id.triggers.zone-id }"
}

resource "aws_route53_record" "A-etcds" {
  count = "${ var.master-count }"

  name = "etcd${ count.index+1 }.${var.cluster["internal-tld"]}"
  ttl  = "300"
  type = "A"

  records = [
    "${ element(split(",", var.master-ips), count.index) }",
  ]

  zone_id = "${ null_resource.interpolated_id.triggers.zone-id }"
}

resource "aws_route53_record" "CNAME-master" {
  name    = "master.${var.cluster["internal-tld"]}"
  records = ["etcd.${var.cluster["internal-tld"]}"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${ null_resource.interpolated_id.triggers.zone-id }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name    = "_etcd-client._tcp.${var.cluster["internal-tld"]}"
  ttl     = "300"
  type    = "SRV"
  records = ["${ formatlist("0 0 2379 %v", aws_route53_record.A-etcds.*.fqdn) }"]
  zone_id = "${ null_resource.interpolated_id.triggers.zone-id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name    = "_etcd-server-ssl._tcp.${var.cluster["internal-tld"]}"
  ttl     = "300"
  type    = "SRV"
  records = ["${ formatlist("0 0 2380 %v", aws_route53_record.A-etcds.*.fqdn) }"]
  zone_id = "${ null_resource.interpolated_id.triggers.zone-id }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_route53_record.etcd-server-tcp",
    "aws_route53_record.A-etcd",
  ]
}
