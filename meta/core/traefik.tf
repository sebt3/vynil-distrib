locals {
    traefik = { for k, v in var.traefik : k => v if k!="enable" && k!="namespace" }
}

resource "kubernetes_namespace_v1" "traefik-ns" {
  count = var.traefik.enable? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.traefik.namespace
  }
}

resource "kubectl_manifest" "traefik" {
  count = var.traefik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.traefik-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "traefik"
      namespace: "${var.traefik.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "share"
      component: "traefik"
      options: ${jsonencode(local.traefik)}
  EOF
}
