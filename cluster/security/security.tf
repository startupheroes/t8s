resource "aws_security_group" "bastion" {
  description = "t8s bastion security group"

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${ var.cidr-allow-ssh }"]
  }

  name = "t8s-bastion-${ var.cluster["cluster-id"] }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "t8s-bastion-${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "master" {
  description = "t8s etcd security group"

  egress = {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    /*self = true*/
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = "${concat(list(var.cidr-vpc), compact(split(",", var.additional-cidr-blocks-master)))}"
  }

  name = "t8s-etcd-${ var.cluster["cluster-id"] }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "t8s-etcd-${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "external-elb" {
  description = "t8s-${ var.cluster["name"] } master (apiserver) external elb"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    /*cidr_blocks = [ "${ var.cidr-vpc }" ]*/
    security_groups = ["${ aws_security_group.master.id }"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  name = "t8s-master-external-elb-${ var.cluster["name"] }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "t8s-master-external-elb-${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "node" {
  description = "t8s node security group"

  egress = {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    /*self = true*/
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["${concat(list(var.cidr-vpc), compact(split(",", var.additional-cidr-blocks-node)))}"]
  }

  name = "t8s-node-${ var.cluster["cluster-id"] }"

  tags {
    builtWith         = "terraform"
    KubernetesCluster = "${ var.cluster["name"] }"
    t8s               = "${ var.cluster["cluster-id"] }"
    Name              = "t8s-node-${ var.cluster["name"] }"
    Version           = "${ var.cluster["version"] }"
  }

  vpc_id = "${ var.vpc-id }"
}
