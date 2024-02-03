locals {
    mayfly = { for k, v in var.tools.mayfly : k => v if k!="enable" }
    reloader = { for k, v in var.tools.reloader : k => v if k!="enable" }
    prometheus = { for k, v in var.tools.prometheus : k => v if k!="enable" }
    opentelemetry = { for k, v in var.tools.opentelemetry : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "tools-ns" {
  count = ( var.tools.prometheus.enable || var.tools.reloader.enable || var.tools.mayfly.enable )? 1 : 0
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

resource "kubectl_manifest" "prometheus" {
  count = var.tools.prometheus.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.tools-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "prometheus"
      namespace: "${var.tools.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "prometheus"
      options: ${jsonencode(local.prometheus)}
  EOF
}

resource "kubectl_manifest" "opentelemetry" {
  count = var.tools.opentelemetry.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.tools-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "opentelemetry"
      namespace: "${var.tools.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "opentelemetry"
      options: ${jsonencode(local.opentelemetry)}
  EOF
}
