resource "template_dir" "manifest" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${format(".cluster/%s/manifests", var.cluster-name)}"

  vars {
    cluster-domain                = "${var.cluster-domain}"
    cluster-name                  = "${var.cluster-name}"
    dns-service-ip                = "${var.dns-service-ip}"
    internal-tld                  = "${var.internal-tld}"
    region                        = "${var.aws["region"]}"
    worker-autoscaling-group-name = "${var.worker-autoscaling-group-name}"
  }
}