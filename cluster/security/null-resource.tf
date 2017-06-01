resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_security_group.master",
    "aws_security_group.external-elb",
    "aws_security_group.node",
  ]
}
