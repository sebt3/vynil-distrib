locals {
    mayfly = { for k, v in var.tools.mayfly : k => v if k!="enable" }
    reloader = { for k, v in var.tools.reloader : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "tools-ns" {
  count = ( var.tools.reloader.enable || var.tools.mayfly.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.tools.namespace
  }
}

resource "kubectl_manifest" "mayfly" {
  count = var.tools.mayfly.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.tools-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "mayfly"
      namespace: "${var.tools.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "mayfly"
      options: ${jsonencode(local.mayfly)}
  EOF
}

resource "kubectl_manifest" "reloader" {
  count = var.tools.reloader.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.tools-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "reloader"
      namespace: "${var.tools.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "reloader"
      options: ${jsonencode(local.reloader)}
  EOF
}
