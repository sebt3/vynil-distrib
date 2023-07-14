locals {
    secret-generator = { for k, v in var.security.secret-generator : k => v if k!="enable" }
    cert-manager = { for k, v in var.security.cert-manager : k => v if k!="enable" }
    letsencrypt = { for k, v in var.security.letsencrypt : k => v if k!="enable" }
    self-sign = { for k, v in var.security.self-sign : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "security-ns" {
  count = ( (var.databases.mariadb.enable || var.security.cert-manager.enable) || var.security.secret-generator.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.security.namespace
  }
}

resource "kubectl_manifest" "secret-generator" {
  count = var.security.secret-generator.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "secret-generator"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "secret-generator"
      options: ${jsonencode(local.secret-generator)}
  EOF
}

resource "kubectl_manifest" "cert-manager" {
  count = (var.databases.mariadb.enable || var.security.cert-manager.enable) ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "cert-manager"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "cert-manager"
      options: ${jsonencode(local.cert-manager)}
  EOF
}

resource "kubectl_manifest" "letsencrypt" {
  count = ((var.databases.mariadb.enable || var.security.cert-manager.enable) && var.security.letsencrypt.enable)? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns, kubectl_manifest.cert-manager]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "cert-manager-letsencrypt"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "cert-manager-letsencrypt"
      options: ${jsonencode(local.letsencrypt)}
  EOF
}

resource "kubectl_manifest" "self-sign" {
  count = ((var.databases.mariadb.enable || var.security.cert-manager.enable) && var.security.self-sign.enable)? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns, kubectl_manifest.cert-manager]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "cert-manager-self-sign"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "core"
      component: "cert-manager-self-sign"
      options: ${jsonencode(local.self-sign)}
  EOF
}
