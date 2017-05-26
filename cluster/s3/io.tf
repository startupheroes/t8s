variable "aws" {
  type = "map"
}

variable "bucket" {}
variable "name" {}

output "bucket" {
  value = "${ aws_s3_bucket.tls.bucket }"
}

output "bucket-arn" {
  value = "${ aws_s3_bucket.tls.arn }"
}
