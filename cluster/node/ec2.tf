resource "aws_launch_configuration" "node" {
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = "${ var.volume_size["ebs"] }"
    volume_type = "gp2"
  }

  iam_instance_profile = "${ var.instance-profile-name }"
  image_id             = "${ var.ami-id }"
  instance_type        = "${ var.instance-type }"
  key_name             = "${ var.aws["key-name"] }"

  # Storage
  root_block_device {
    volume_size = "${ var.volume_size["root"] }"
    volume_type = "gp2"
  }

  security_groups = [
    "${ var.security-group-id }",
  ]

  user_data = "${ data.template_file.cloud-config-fetcher.rendered }"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "aws_autoscaling_group" "node" {
  name = "node-${ var.node-name }-${ var.cluster["cluster-id"] }"

  desired_capacity          = "${ var.capacity["desired"] }"
  health_check_grace_period = 60
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${ aws_launch_configuration.node.name }"
  max_size                  = "${ var.capacity["max"] }"
  min_size                  = "${ var.capacity["min"] }"
  vpc_zone_identifier       = ["${ split(",", var.subnet-ids) }"]

  load_balancers = ["${compact(split(",", var.load-balancers))}"]

  tag {
    key                 = "builtWith"
    value               = "terraform"
    propagate_at_launch = true
  }

  # used by kubelet's aws provider to determine cluster
  tag {
    key                 = "KubernetesCluster"
    value               = "${ var.cluster["name"] }"
    propagate_at_launch = true
  }

  tag {
    key                 = "t8s"
    value               = "${ var.cluster["cluster-id"] }"
    propagate_at_launch = true
  }

  tag {
    key                 = "Version"
    value               = "${ var.cluster["version"] }"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "t8s-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "node"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s-version"
    value               = "${ var.k8s["hyperkube-tag"] }"
    propagate_at_launch = true
  }

  tag {
    key                 = "visibility"
    value               = "private"
    propagate_at_launch = true
  }
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_autoscaling_group.node",
    "aws_launch_configuration.node",
  ]
}
