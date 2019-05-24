data "aws_subnet" "private_subnet" {
  id = "${ element(split( ",",var.subnet-ids-private ), 0) }"
}

resource "null_resource" "master" {
  count = "${ var.master-count }"

  triggers =  {
    ip = "${cidrhost(data.aws_subnet.private_subnet.cidr_block, var.master-cidr-offset + count.index )}"
  }
}
