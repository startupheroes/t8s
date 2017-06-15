resource "null_resource" "waiting-cluster-null-resource" {
  triggers {
    test = "${var.cluster["cluster-id"]}"
  }

  provisioner "local-exec" {
    command = "until curl --insecure https://${var.external-elb} &>/dev/null; do echo \"Waiting api server. (It might take around 5 min)\"; sleep 10; done"
  }
}

resource "local_file" "ca-file" {
  content  = "${var.tls-ca-self-signed-cert-pem}"
  filename = "${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.ca-file}"
}

resource "local_file" "admin-key-file" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.admin-key-file}"
}

resource "local_file" "admin-file" {
  content  = "${tls_locally_signed_cert.admin.cert_pem}"
  filename = "${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.admin-file}"
}

resource "null_resource" "id_rsa_file" {
  depends_on = ["null_resource.waiting-cluster-null-resource"]

  triggers {
    test = "${var.cluster["cluster-id"]}"
  }

  provisioner "local-exec" {
    command = <<EOT

    kubectl config set-cluster cluster-${var.cluster["cluster-id"]} \
     --embed-certs=true --server=https://${var.external-elb} \
     --certificate-authority=${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.ca-file}

    kubectl config set-credentials admin-${var.cluster["cluster-id"]} \
      --embed-certs=true \
      --certificate-authority=${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.ca-file} \
      --client-key=${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.admin-key-file} \
      --client-certificate=${path.root}/.cluster/${var.cluster["name"]}/${var.cluster["version"]}/${var.dir-tls}/${var.admin-file}

    kubectl config set-context ${var.cluster["cluster-id"]} \
      --cluster=cluster-${var.cluster["cluster-id"]} \
      --user=admin-${var.cluster["cluster-id"]}

    kubectl config use-context ${var.cluster["cluster-id"]}

    kubectl create -f ${format("%s/.cluster/%s/%s/manifests", path.root, var.cluster["name"], var.cluster["version"])}/configmap
    kubectl create -f ${format("%s/.cluster/%s/%s/manifests", path.root, var.cluster["name"], var.cluster["version"])}/dns
    kubectl create -f ${format("%s/.cluster/%s/%s/manifests", path.root, var.cluster["name"], var.cluster["version"])}/dashboard
    kubectl create -f ${format("%s/.cluster/%s/%s/manifests", path.root, var.cluster["name"], var.cluster["version"])}/rescheduler

EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = ""

    command = <<EOT
    kubectl config delete-cluster cluster-${var.cluster["cluster-id"]}
    kubectl config unset users.admin-${var.cluster["cluster-id"]}
    kubectl config delete-context ${var.cluster["cluster-id"]}
    rm -rf ${path.root}/.cluster/${var.cluster["cluster-id"]}/${var.dir-tls}
EOT
  }
}
