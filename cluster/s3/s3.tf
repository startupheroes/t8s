resource "aws_s3_bucket" "tls" {
  acl           = "private"
  bucket        = "t8s-cloud-init-${var.cluster["cluster-id"]}-${ var.aws["region"] }"
  force_destroy = true

  region = "${ var.aws["region"] }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }
}
