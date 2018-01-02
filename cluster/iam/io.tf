variable "cluster" {
  type = "map"

  default = {
    name             = ""
    version          = ""
    cluster-id       = ""
    cluster-tld      = ""
    cluster-root-tld = ""
  }
}

variable "s3-bucket-arn" {}

data "aws_caller_identity" "current" {}

output "depends-id" {
  value = "${ null_resource.dummy_dependency.id }"
}

output "aws-iam-role-etcd-id" {
  value = "${ aws_iam_role.master.id }"
}

output "aws-iam-role-node-id" {
  value = "${ aws_iam_role.node.id }"
}

output "instance-profile-name-master" {
  value = "${ aws_iam_instance_profile.master.name }"
}

output "instance-profile-name-node" {
  value = "${ aws_iam_instance_profile.node.name }"
}
