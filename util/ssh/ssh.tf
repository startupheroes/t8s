resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

data "template_file" "id-rsa-private" {
  template = "$${key}}"

  vars {
    key = "${tls_private_key.ssh_key.private_key_pem}"
  }
}

data "template_file" "id-rsa-public" {
  template = "$${key}"

  vars {
    key = "${tls_private_key.ssh_key.public_key_openssh}"
  }
}

resource "local_file" "id-rsa-file" {
  content  = "${data.template_file.id-rsa-private.rendered}"
  filename = "${var.output-private-file}"
}

resource "local_file" "id-rsa-pub-file" {
  content  = "${data.template_file.id-rsa-public.rendered}"
  filename = "${var.output-public-file}"
}
