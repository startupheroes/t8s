resource "null_resource" "waiting-cluster-null-resource" {
  triggers {
    test = "${var.cluster-name}"
  }

  provisioner "local-exec" {
    command = "until curl --insecure https://${var.external-elb} &>/dev/null; do echo \"Waiting api server...\"; sleep 10; done"
  }
}

resource "local_file" "ca-file" {
  content  = "${var.tls-ca-self-signed-cert-pem}"
  filename = "${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file}"
}

resource "local_file" "admin-key-file" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-key-file}"
}

resource "local_file" "admin-file" {
  content  = "${tls_locally_signed_cert.admin.cert_pem}"
  filename = "${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-file}"
}

resource "null_resource" "id_rsa_file" {
  depends_on = ["null_resource.waiting-cluster-null-resource"]

  triggers {
    test = "${var.cluster-name}"
  }

  provisioner "local-exec" {
    command = <<EOT

    kubectl config set-cluster cluster-${var.cluster-name} \
     --embed-certs=true --server=https://${var.external-elb} \
     --certificate-authority=${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file}

    kubectl config set-credentials admin-${var.cluster-name} \
      --embed-certs=true \
      --certificate-authority=${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.ca-file} \
      --client-key=${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-key-file} \
      --client-certificate=${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}/${var.admin-file}

    kubectl config set-context ${var.cluster-name} \
      --cluster=cluster-${var.cluster-name} \
      --user=admin-${var.cluster-name}

    kubectl config use-context ${var.cluster-name}

    kubectl create -f ${format("%s/.cluster/%s/manifests", path.root, var.cluster-name)}/configmap
    kubectl create -f ${format("%s/.cluster/%s/manifests", path.root, var.cluster-name)}/dns
    kubectl create -f ${format("%s/.cluster/%s/manifests", path.root, var.cluster-name)}/dashboard
    kubectl create -f ${format("%s/.cluster/%s/manifests", path.root, var.cluster-name)}/rescheduler

EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = ""

    command = <<EOT
    kubectl config delete-cluster cluster-${var.cluster-name}
    kubectl config unset users.admin-${var.cluster-name}
    kubectl config delete-context ${var.cluster-name}
    rm -rf ${path.root}/.cluster/${var.cluster-name}/${var.dir-tls}
EOT
  }
}
