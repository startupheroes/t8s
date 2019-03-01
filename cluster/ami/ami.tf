data "aws_ami" "coreos" {
  most_recent = true

  owners = ["${var.owner-id}"]

  filter {
    name   = "owner-id"
    values = ["${var.owner-id}"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-${var.channel}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
