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
}

resource "kubernetes_namespace_v1" "infra-ns" {
  count = ( var.traefik.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = merge(local.common-labels, local.annotations)
    name = "${var.namespace}-infra"
  }
}

resource "kubectl_manifest" "traefik" {
  count = var.traefik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.infra-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "traefik"
      namespace: "${var.namespace}-infra"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "apps"
      component: "traefik-ui"
      options: ${jsonencode(merge(local.global, local.traefik))}
  EOF
}
