resource "aws_instance" "master" {
  count = "${ var.master-count }"

  ami                         = "${ var.ami-id }"
  associate_public_ip_address = false
  iam_instance_profile        = "${ var.instance-profile-name }"
  instance_type               = "${ var.instance-type }"
  key_name                    = "${ var.aws["key-name"] }"
  private_ip                  = "${ element(split(",", var.master-ips), count.index) }"

  root_block_device {
    volume_size = 124
    volume_type = "gp2"
  }

  source_dest_check = true
  subnet_id         = "${ var.subnet-id-private }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    role              = "etcd,apiserver"
    Name              = "t8s-etcd${ count.index + 1 }"
    Version           = "${ var.cluster["version"] }"
    k8s-version       = "${ var.k8s["hyperkube-tag"] }"
    visibility        = "private"
  }

  user_data              = "${ element(data.template_file.cloud-config-fetcher.*.rendered, count.index) }"
  vpc_security_group_ids = ["${ var.etcd-security-group-id }"]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = ["aws_instance.master"]
}
