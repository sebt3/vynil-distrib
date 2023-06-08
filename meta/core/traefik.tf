locals {
    traefik = { for k, v in var.traefik : k => v if k!="enable" && k!="namespace" }
}

resource "kubernetes_namespace_v1" "traefik-ns" {
  count = var.traefik.enable? 1 : 0
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
    name = var.traefik.namespace
  }
}

resource "kubernetes_manifest" "traefik" {
  count = var.traefik.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.traefik-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "traefik"
      "namespace" = var.traefik.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "share"
      "component" = "traefik"
      "options" = local.traefik
    }
  }
}
