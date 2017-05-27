resource "local_file" "ca-file" {
  content  = "${var.tls-ca-self-signed-cert-pem}"
  filename = ".cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file}"
}

resource "local_file" "admin-key-file" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = ".cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-key-file}"
}

resource "local_file" "admin-file" {
  content  = "${tls_locally_signed_cert.admin.cert_pem}"
  filename = ".cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-file}"
}

resource "null_resource" "id_rsa_file" {
  triggers {
    test = "${var.cluster-name}"
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl config set-cluster cluster-${var.cluster-name} \
     --embed-certs=true --server=https://${var.external-elb} \
     --certificate-authority=.cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file}

    kubectl config set-credentials admin-${var.cluster-name} \
      --embed-certs=true \
      --certificate-authority=.cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file} \
      --client-key=.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-key-file} \
      --client-certificate=.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-file}

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
    rm -rf .cluster/${var.cluster-name}/${var.dir-tls}
EOT
  }
}
