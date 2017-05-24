resource "aws_key_pair" "ssh_aws_key" {
  key_name   = "${var.name}"
  public_key = "${var.public-file}"
}
