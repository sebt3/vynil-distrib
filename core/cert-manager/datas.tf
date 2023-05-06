
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
}
