locals {
    global = {
        "domain-name" = var.domain-name
    }
}
resource "kubernetes_manifest" "installs" {
  count = length(var.metas)
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = try(var.metas[count.index].component, "auth")
      "namespace" = var.namespace
    }
    "spec" = {
      "distrib" = try(var.metas[count.index].distrib, var.default-dist)
      "category" = "meta"
      "component" = "domain-${try(var.metas[count.index].component, "auth")}"
      "options" = merge(local.global, try(var.metas[count.index].options, {}))
    }
  }
}
