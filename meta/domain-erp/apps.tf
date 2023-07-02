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
    dolibarr = { for k, v in var.dolibarr : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "erp-ns" {
  count = ( var.dolibarr.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = merge(local.common-labels, local.annotations)
    name = "${var.namespace}-erp"
  }
}

resource "kubectl_manifest" "dolibarr" {
  count = var.dolibarr.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.erp-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dolibarr"
      namespace: "${kubernetes_namespace_v1.erp-ns[0].metadata[0].name}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "apps"
      component: "dolibarr"
      options: ${jsonencode(merge(local.global, local.dolibarr))}
  EOF
}
