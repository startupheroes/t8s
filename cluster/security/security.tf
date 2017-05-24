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

  name = "t8s-bastion-${ var.name }"

  tags {
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-bastion-${ var.name }"
    builtWith         = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "etcd" {
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
    cidr_blocks = ["${ var.cidr-vpc }"]
  }

  name = "t8s-etcd-${ var.name }"

  tags {
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-etcd-${ var.name }"
    builtWith         = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "external-elb" {
  description = "t8s-${ var.name } master (apiserver) external elb"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    /*cidr_blocks = [ "${ var.cidr-vpc }" ]*/
    security_groups = ["${ aws_security_group.etcd.id }"]
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

  name = "t8s-master-external-elb-${ var.name }"

  tags {
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-master-external-elb-${ var.name }"
    builtWith         = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}

resource "aws_security_group" "worker" {
  description = "t8s worker security group"

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
    cidr_blocks = ["${ var.cidr-vpc }"]
  }

  name = "t8s-worker-${ var.name }"

  tags {
    KubernetesCluster = "${ var.name }"
    t8s               = "${ var.name }"
    Name              = "t8s-worker-${ var.name }"
    builtWith         = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
}
