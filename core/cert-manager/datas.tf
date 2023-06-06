
data "kustomization_overlay" "data" {
  resources = [
    "https://github.com/cert-manager/cert-manager/releases/download/v${var.release}/cert-manager.yaml",
  ]
  images {
    name = "quay.io/jetstack/cert-manager-cainjector"
    new_name = "${var.images.cainjector.registry}/${var.images.cainjector.repository}"
    new_tag = "${var.images.cainjector.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-controller"
    new_name = "${var.images.controller.registry}/${var.images.controller.repository}"
    new_tag = "${var.images.controller.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-webhook"
    new_name = "${var.images.webhook.registry}/${var.images.webhook.repository}"
    new_tag = "${var.images.webhook.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-ctl"
    new_name = "${var.images.startupapicheck.registry}/${var.images.startupapicheck.repository}"
    new_tag = "${var.images.startupapicheck.tag}"
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "clusterissuers.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: clusterissuers.cert-manager.io
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "challenges.acme.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: challenges.acme.cert-manager.io
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "certificaterequests.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: certificaterequests.cert-manager.io
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "issuers.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: issuers.cert-manager.io
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "certificates.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: certificates.cert-manager.io
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "orders.acme.cert-manager.io"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: orders.acme.cert-manager.io
    EOF
  }
}
