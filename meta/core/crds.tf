locals {
    crd-prometheus = { for k, v in var.crds.prometheus : k => v if k!="enable" }
    crd-traefik = { for k, v in var.crds.traefik : k => v if k!="enable" }
    crd-redis = { for k, v in var.crds.redis : k => v if k!="enable" }
}

resource "kubernetes_manifest" "crd-prometheus" {
  count = (var.crds.prometheus.enable || var.databases.mariadb.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-prometheus"
      "namespace" = var.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "prometheus"
      "options" = local.crd-prometheus
    }
  }
}

resource "kubernetes_manifest" "crd-traefik" {
  count = var.crds.traefik.enable ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-traefik"
      "namespace" = var.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "traefik"
      "options" = local.crd-traefik
    }
  }
}

resource "kubernetes_manifest" "crd-redis" {
  count = (var.crds.redis.enable || var.databases.redis.enable)? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-redis"
      "namespace" = var.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "dbo-redis"
      "options" = local.crd-redis
    }
  }
}
