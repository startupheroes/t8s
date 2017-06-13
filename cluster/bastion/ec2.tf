resource "aws_instance" "bastion" {
  ami                         = "${ var.ami-id }"
  associate_public_ip_address = true
  instance_type               = "${ var.instance-type }"
  key_name                    = "${ var.key-name }"

  source_dest_check = true
  subnet_id         = "${ var.subnet-id }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    depends-id        = "${ var.depends-id }"
    Name              = "t8s-bastion-${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
    role              = "bastion"
    visibility        = "public"
  }

  user_data = "${ data.template_file.cloud-config.rendered }"

  vpc_security_group_ids = [
    "${ var.security-group-id }",
  ]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = ["aws_instance.bastion"]
}
