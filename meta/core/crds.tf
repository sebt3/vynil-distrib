locals {
    labels = {
      "vynil.solidite.fr/owner-namespace" = var.namespace
      "vynil.solidite.fr/owner-category" = "meta"
      "vynil.solidite.fr/owner-component" = "core"
      "app.kubernetes.io/managed-by" = "vynil"
    }
    annotations = {
      "vynil.solidite.fr/meta" = "core"
      "vynil.solidite.fr/name" = var.namespace
    }
    crd-prometheus = { for k, v in var.crds.prometheus : k => v if k!="enable" }
    crd-k8up = { for k, v in var.crds.k8up : k => v if k!="enable" }
    crd-secret-generator = { for k, v in var.crds.secret-generator : k => v if k!="enable" }
    crd-cert-manager = { for k, v in var.crds.cert-manager : k => v if k!="enable" }
    crd-traefik = { for k, v in var.crds.traefik : k => v if k!="enable" }
    crd-redis = { for k, v in var.crds.redis : k => v if k!="enable" }
    crd-mariadb = { for k, v in var.crds.mariadb : k => v if k!="enable" }
    crd-rabbitmq = { for k, v in var.crds.rabbitmq : k => v if k!="enable" }
}

resource "kubernetes_manifest" "crd-prometheus" {
  count = (var.crds.prometheus.enable || var.databases.mariadb.enable || var.security.secret-generator.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-prometheus"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "prometheus"
      "options" = local.crd-prometheus
    }
  }
}

resource "kubernetes_manifest" "crd-cert-manager" {
  count = (var.crds.cert-manager.enable || var.security.cert-manager.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-cert-manager"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "cert-manager"
      "options" = local.crd-cert-manager
    }
  }
}

resource "kubernetes_manifest" "crd-secret-generator" {
  count = (var.crds.secret-generator.enable || var.security.secret-generator.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-secret-generator"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "secret-generator"
      "options" = local.crd-cert-manager
    }
  }
}

resource "kubernetes_manifest" "crd-k8up" {
  count = (var.crds.k8up.enable || var.backup.k8up.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-k8up"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "k8up"
      "options" = local.crd-cert-manager
    }
  }
}

resource "kubernetes_manifest" "crd-traefik" {
  count = (var.crds.traefik.enable || var.traefik.enable) ? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-traefik"
      "namespace" = var.namespace
      "labels" = local.labels
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
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "redis"
      "options" = local.crd-redis
    }
  }
}

resource "kubernetes_manifest" "crd-mariadb" {
  count = (var.crds.mariadb.enable || var.databases.mariadb.enable)? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-mariadb"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "mariadb"
      "options" = local.crd-mariadb
    }
  }
}

resource "kubernetes_manifest" "crd-rabbitmq" {
  count = (var.crds.rabbitmq.enable || var.databases.rabbitmq.enable)? 1 : 0
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "crd-rabbitmq"
      "namespace" = var.namespace
      "labels" = local.labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "crd"
      "component" = "rabbitmq"
      "options" = local.crd-rabbitmq
    }
  }
}
