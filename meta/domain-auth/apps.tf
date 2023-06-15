locals {
    annotations = {
      "vynil.solidite.fr/meta" = "domain-auth"
      "vynil.solidite.fr/name" = "${var.namespace}-auth"
      "vynil.solidite.fr/domain" = var.domain-name
      "vynil.solidite.fr/issuer" = var.issuer
      "vynil.solidite.fr/ingress" = var.ingress-class
    }
    global = {
        "domain" = var.namespace
        "domain-name" = var.domain-name
        "issuer" = var.issuer
        "ingress-class" = var.ingress-class
    }
    authentik = { for k, v in var.authentik : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "auth-ns" {
  count = var.authentik.enable? 1 : 0
  metadata {
    annotations = local.annotations
    labels = merge(local.common-labels, local.annotations)
    name = "${var.namespace}-auth"
  }
}

resource "kubectl_manifest" "authentik" {
  count = var.authentik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.auth-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "authentik"
      namespace: "${var.namespace}-auth"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "share"
      component: "authentik"
      options: ${jsonencode(merge(local.global, local.authentik))}
  EOF
}
