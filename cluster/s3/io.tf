variable "aws" {
  type = "map"
}

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

output "bucket" {
  value = "${ aws_s3_bucket.tls.bucket }"
}

output "bucket-arn" {
  value = "${ aws_s3_bucket.tls.arn }"
}
