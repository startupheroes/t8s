variable "azs" {}
variable "cidr" {}
variable "cidr-step-private-subnet" {}
variable "cidr-offset-subnet" {}
variable "cidr-newbits" {}
variable "depends-id" {}
variable "name" {}
variable "region" {}

output "depends-id" {
  value = "${null_resource.dummy_dependency.id}"
}

output "gateway-id" {
  value = "${ aws_internet_gateway.main.id }"
}

output "id" {
  value = "${ aws_vpc.main.id }"
}

output "route-table-id" {
  value = "${ aws_route_table.private.id }"
}

output "subnet-ids-private" {
  value = "${ join(",", aws_subnet.private.*.id) }"
}

output "subnet-ids-public" {
  value = "${ join(",", aws_subnet.public.*.id) }"
}

output "subnet-ids-private-cidr" {
  value = "${ join(",", aws_subnet.private.*.cidr_block) }"
}

output "subnet-ids-public-cidr" {
  value = "${ join(",", aws_subnet.public.*.cidr_block) }"
}
