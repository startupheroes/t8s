resource "local_file" "ca-file" {
  content  = "${var.tls-ca-self-signed-cert-pem}"
  filename = "${var.dir-tls}/${var.cluster-name}/${var.ca-file}"
}

resource "local_file" "admin-key-file" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "${var.dir-tls}/${var.cluster-name}/${var.admin-key-file}"
}

resource "local_file" "admin-file" {
  content  = "${tls_locally_signed_cert.admin.cert_pem}"
  filename = "${var.dir-tls}/${var.cluster-name}/${var.admin-file}"
}

resource "null_resource" "id_rsa_file" {
  triggers {
    test = "${var.cluster-name}"
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl config set-cluster cluster-${var.cluster-name} \
     --embed-certs=true --server=https://${var.external-elb} \
     --certificate-authority=${var.dir-tls}/${var.cluster-name}/${var.ca-file}

    kubectl config set-credentials admin-${var.cluster-name} \
      --embed-certs=true \
      --certificate-authority=${var.dir-tls}/${var.cluster-name}/${var.ca-file} \
      --client-key=${var.dir-tls}/${var.cluster-name}/${var.admin-key-file} \
      --client-certificate=${var.dir-tls}/${var.cluster-name}/${var.admin-file}

    kubectl config set-context ${var.cluster-name} \
      --cluster=cluster-${var.cluster-name} \
      --user=admin-${var.cluster-name}
EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = ""

    command = <<EOT
    kubectl config delete-cluster cluster-${var.cluster-name}
    kubectl config unset users.admin-${var.cluster-name}
    kubectl config delete-context ${var.cluster-name}
    rm -rf ${var.dir-tls}/${var.cluster-name}
EOT
  }
}
