data  "aws_subnet" "private_subnet"{
  id = "${ element(split( ",",var.subnet-ids-private ), 0) }"
}

data "template_file" "master" {
  count    = "${ var.master-count }"
  template = "${cidrhost(data.aws_subnet.private_subnet.cidr_block, var.master-cidr-offset + count.index )}"
}