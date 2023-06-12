locals {
    annotations = {
      "vynil.solidite.fr/meta" = "domain-ci"
      "vynil.solidite.fr/name" = var.namespace
      "vynil.solidite.fr/domain" = var.domain-name
      "vynil.solidite.fr/issuer" = var.issuer
    }
    global = {
        "domain" = var.namespace
        "domain-name" = var.domain-name
        "issuer" = var.issuer
        "ingress-class" = var.ingress-class
    }
    gitea = { for k, v in var.gitea : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "ci-ns" {
  count = ( var.gitea.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = "${var.namespace}-ci"
  }
}

resource "kubernetes_manifest" "gitea" {
  count = var.gitea.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.ci-ns]
  manifest = {
    apiVersion = "vynil.solidite.fr/v1"
    kind       = "Install"
    metadata   = {
      name      = "gitea"
      namespace = "${var.namespace}-ci"
      labels    = local.common-labels
    }
    spec = {
      distrib = "core"
      category = "apps"
      component = "gitea"
      options = merge(local.global, local.gitea)
    }
  }
}
