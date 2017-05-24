data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    internal-tld = "${ var.internal-tld }"
  }
}
