locals {
    k8up = { for k, v in var.backup.k8up : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "backup-ns" {
  count = var.backup.k8up.enable? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.labels
    name = var.backup.namespace
  }
}

resource "kubernetes_manifest" "k8up" {
  count = var.backup.k8up.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.backup-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "k8up"
      "namespace" = var.backup.namespace
      "labels" = local.common-labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "k8up"
      "options" = local.k8up
    }
  }
}
