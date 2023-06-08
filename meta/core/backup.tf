locals {
    k8up = { for k, v in var.backup.k8up : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "backup-ns" {
  count = var.backup.k8up.enable? 1 : 0
  metadata {
    annotations = {
      "vynil.solidite.fr/meta" = "core"
      "vynil.solidite.fr/name" = var.namespace
    }
    labels = {
      "vynil.solidite.fr/owner-namespace" = var.namespace
      "vynil.solidite.fr/owner-category" = "meta"
      "vynil.solidite.fr/owner-component" = "core"
      "app.kubernetes.io/managed-by" = "vynil"
    }
    name = var.backup.namespace
  }
}

resource "kubernetes_manifest" "backup" {
  count = var.backup.k8up.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.backup-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "backup"
      "namespace" = var.security.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "k8up"
      "options" = local.k8up
    }
  }
}
