variable "name" {}
variable "s3-bucket-arn" {}

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
