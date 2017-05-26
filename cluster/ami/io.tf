variable "channel" {
  type    = "string"
  default = "stable"
}

variable "owner-id" {
  type    = "string"
  default = "595879546273"
}

output "ami_id" {
  value = "${data.aws_ami.coreos.id}"
}

output "ami_description" {
  value = "${data.aws_ami.coreos.description}"
}
