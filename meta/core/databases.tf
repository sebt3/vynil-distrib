locals {
    postgresql = { for k, v in var.databases.postgresql : k => v if k!="enable" }
    redis = { for k, v in var.databases.redis : k => v if k!="enable" }
    rabbitmq = { for k, v in var.databases.rabbitmq : k => v if k!="enable" }
    mariadb = { for k, v in var.databases.mariadb : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "databases-ns" {
  count = ( var.databases.postgresql.enable || var.databases.redis.enable || var.databases.rabbitmq.enable || var.databases.mariadb.enable )? 1 : 0
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
    name = var.databases.namespace
  }
}

resource "kubernetes_manifest" "dbo-postgresql" {
  count = var.databases.postgresql.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "dbo-pg"
      "namespace" = var.databases.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "dbo"
      "component" = "postgresql"
      "options" = local.postgresql
    }
  }
}

resource "kubernetes_manifest" "dbo-redis" {
  count = var.databases.redis.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns,kubernetes_manifest.crd-redis]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "dbo-redis"
      "namespace" = var.databases.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "dbo"
      "component" = "redis"
      "options" = local.redis
    }
  }
}

resource "kubernetes_manifest" "rabbitmq" {
  count = var.databases.rabbitmq.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "dbo-rabbitmq"
      "namespace" = var.databases.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "dbo"
      "component" = "rabbitmq"
      "options" = local.letsencrypt
    }
  }
}

resource "kubernetes_manifest" "mariadb" {
  count = var.databases.mariadb.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns, kubernetes_manifest.crd-prometheus]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "dbo-mariadb"
      "namespace" = var.databases.namespace
      "labels" = {
        "vynil.solidite.fr/owner-namespace" = var.namespace
        "vynil.solidite.fr/owner-category" = "meta"
        "vynil.solidite.fr/owner-component" = "core"
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "distrib" = "core"
      "category" = "dbo"
      "component" = "mariadb"
      "options" = local.mariadb
    }
  }
}
