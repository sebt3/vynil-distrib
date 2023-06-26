locals {
    flux = { for k, v in var.flux : k => v if k!="enable" && k!="namespace" }
}

resource "kubernetes_namespace_v1" "flux-ns" {
  count = var.flux.enable? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.flux.namespace
  }
}

resource "kubectl_manifest" "flux" {
  count = var.flux.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.flux-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "flux"
      namespace: "${var.flux.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "flux"
      options: ${jsonencode(local.flux)}
  EOF
}
