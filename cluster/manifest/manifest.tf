resource "template_dir" "manifest" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${format("%s/.cluster/%s/%s/manifests", path.root, var.cluster["name"], var.cluster["version"])}"

  vars {
    cluster-domain              = "${var.cluster-domain}"
    dns-service-ip              = "${var.dns-service-ip}"
    internal-tld                = "${var.cluster["internal-tld"]}"
    region                      = "${var.aws["region"]}"
    node-autoscaling-group-name = "${var.node-autoscaling-group-name}"
  }
}
