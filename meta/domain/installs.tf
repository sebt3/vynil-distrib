locals {
    global = {
        "domain"         = var.namespace
        "domain-name"    = var.domain-name
        "issuer"         = var.issuer
        "ingress-class"  = var.ingress-class
    }
    annotations = {
      "vynil.solidite.fr/meta" = "domain"
      "vynil.solidite.fr/name" = var.namespace
      "vynil.solidite.fr/domain" = var.domain-name
      "vynil.solidite.fr/issuer" = var.issuer
    }
    auth = { for k, v in var.auth : k => v if k!="enable" }
    infra = { for k, v in var.infra : k => v if k!="enable" }
    ci = { for k, v in var.ci : k => v if k!="enable" }
}

resource "kubectl_manifest" "auth" {
  count = var.auth.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "auth"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-auth"
      options: ${jsonencode(merge(local.global, local.auth))}
  EOF
}
resource "kubectl_manifest" "infra" {
  count = var.infra.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "infra"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-infra"
      options: ${jsonencode(merge(local.global, local.infra))}
  EOF
}
resource "kubectl_manifest" "ci" {
  count = var.ci.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "ci"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-ci"
      options: ${jsonencode(merge(local.global, local.ci))}
  EOF
}
