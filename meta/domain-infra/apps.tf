locals {
    annotations = {
      "vynil.solidite.fr/meta"   = "domain-ci"
      "vynil.solidite.fr/name"   = var.namespace
      "vynil.solidite.fr/domain" = var.domain-name
      "vynil.solidite.fr/issuer" = var.issuer
      "vynil.solidite.fr/ingress" = var.ingress-class
    }
    global = {
        "domain"        = var.namespace
        "domain-name"   = var.domain-name
        "issuer"        = var.issuer
        "ingress-class" = var.ingress-class
    }
    traefik = { for k, v in var.traefik : k => v if k!="enable" }
    dns = { for k, v in var.dns : k => v if k!="enable" }
    api = { for k, v in var.api : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "infra-ns" {
  count = ( var.dns.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = merge(local.common-labels, local.annotations)
    name = "${var.namespace}-infra"
  }
}

resource "kubectl_manifest" "dns" {
  count = var.dns.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.infra-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dns"
      namespace: "${kubernetes_namespace_v1.infra-ns.name}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "share"
      component: "dns"
      options: ${jsonencode(merge(local.global, local.dns))}
  EOF
}

resource "kubectl_manifest" "traefik" {
  count = var.traefik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.infra-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "traefik-ui-${var.namespace}"
      namespace: "${var.traefik.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "apps"
      component: "traefik-ui"
      options: ${jsonencode(merge(local.global, local.traefik))}
  EOF
}
resource "kubectl_manifest" "traefik" {
  count = var.traefik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.infra-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "k8s-api-${var.namespace}"
      namespace: "default"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "apps"
      component: "k8s-ui"
      options: ${jsonencode(merge(local.global, local.api))}
  EOF
}
