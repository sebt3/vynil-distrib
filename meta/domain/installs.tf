locals {
    global = {
        "domain"         = var.namespace
        "domain-name"    = var.domain-name
        "issuer"         = var.issuer
        "ingress-class"  = var.ingress-class
    }
}
resource "kubectl_manifest" "installs" {
  count = length(var.metas)
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "${try(var.metas[count.index].component, "auth")}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${try(var.metas[count.index].distrib, var.default-dist)}"
      category: "meta"
      component: "domain-${try(var.metas[count.index].component, "auth")}"
      options: ${jsonencode(merge(local.global, try(var.metas[count.index].options, {})))}
  EOF
}
