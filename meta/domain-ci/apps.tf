locals {
    annotations = {
      "vynil.solidite.fr/meta"    = "domain-ci"
      "vynil.solidite.fr/name"    = var.namespace
      "vynil.solidite.fr/domain"  = var.domain-name
      "vynil.solidite.fr/issuer"  = var.issuer
      "vynil.solidite.fr/ingress" = var.ingress-class
    }
    global = {
        "domain"         = var.namespace
        "domain-name"    = var.domain-name
        "issuer"         = var.issuer
        "ingress-class"  = var.ingress-class
    }
    gitea = { for k, v in var.gitea : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "ci-ns" {
  count = ( var.gitea.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = merge(local.common-labels, local.annotations)
    name = "${var.namespace}-ci"
  }
}

resource "kubectl_manifest" "gitea" {
  count = var.gitea.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.ci-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "gitea"
      namespace: "${var.namespace}-ci"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "apps"
      component: "gitea"
      options: ${jsonencode(merge(local.global, local.gitea))}
  EOF
}
