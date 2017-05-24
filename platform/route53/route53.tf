resource "aws_route53_zone" "internal" {
  comment = "Kubernetes [t8s] cluster DNS (internal)"
  name    = "${ var.internal-tld }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "k8s-${ var.name }"
  }

  vpc_id = "${ var.vpc-id }"
}
