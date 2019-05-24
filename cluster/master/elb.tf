resource "aws_elb" "external" {
  name = "t8s-apiserver-${replace(var.cluster["cluster-id"], "/[[:^alnum:]]/", "")}"

  cross_zone_load_balancing = false

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 3
    target              = "SSL:443"
    interval            = 10
  }

  idle_timeout = 3600

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  security_groups = ["${ var.external-elb-security-group-id }"]
  subnets         = ["${ var.subnet-id-public }"]

  tags = {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Version           = "${ var.cluster["version"] }"
    Name              = "t8s-apiserver"
    role              = "apiserver"
    k8s-version       = "${ var.k8s["hyperkube-tag"] }"
    visibility        = "public"
  }
}

resource "aws_elb_attachment" "master" {
  count = "${ var.master-count }"

  elb      = "${ aws_elb.external.id }"
  instance = "${ element(aws_instance.master.*.id, count.index) }"
}
