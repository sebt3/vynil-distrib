locals {
    hnc = { for k, v in var.security.hnc : k => v if k!="enable" }
    kyverno = { for k, v in var.security.kyverno : k => v if k!="enable" }
    capsule = { for k, v in var.security.capsule : k => v if k!="enable" }
    secret-generator = { for k, v in var.security.secret-generator : k => v if k!="enable" }
    cert-manager = { for k, v in var.security.cert-manager : k => v if k!="enable" }
    letsencrypt = { for k, v in var.security.letsencrypt : k => v if k!="enable" }
    self-sign = { for k, v in var.security.self-sign : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "security-ns" {
  count = ( var.security.hnc.enable || var.security.kyverno.enable || (var.databases.mariadb.enable || var.security.cert-manager.enable) || var.security.secret-generator.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.security.namespace
  }
}

resource "kubectl_manifest" "capsule" {
  count = var.security.capsule.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "capsule"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "core"
      component: "capsule"
      options: ${jsonencode(local.capsule)}
  EOF
}

resource "kubectl_manifest" "kyverno" {
  count = var.security.kyverno.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "kyverno"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "core"
      component: "kyverno"
      options: ${jsonencode(local.kyverno)}
  EOF
}

resource "kubectl_manifest" "hnc" {
  count = var.security.hnc.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "hnc"
      namespace: "${var.security.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "core"
      component: "hnc"
      options: ${jsonencode(local.hnc)}
  EOF
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
      category: "core"
      component: "cert-manager-self-sign"
      options: ${jsonencode(local.self-sign)}
  EOF
}
