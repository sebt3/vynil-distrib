locals {
    secret-generator = { for k, v in var.security.secret-generator : k => v if k!="enable" }
    cert-manager = { for k, v in var.security.cert-manager : k => v if k!="enable" }
    letsencrypt = { for k, v in var.security.letsencrypt : k => v if k!="enable" }
    self-sign = { for k, v in var.security.self-sign : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "security-ns" {
  count = ( (var.databases.mariadb.enable || var.security.cert-manager.enable) || var.security.secret-generator.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.security.namespace
  }
}

resource "kubernetes_manifest" "secret-generator" {
  count = var.security.secret-generator.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "secret-generator"
      "namespace" = var.security.namespace
      "labels" = local.common-labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "secret-generator"
      "options" = local.secret-generator
    }
  }
}

resource "kubernetes_manifest" "cert-manager" {
  count = (var.databases.mariadb.enable || var.security.cert-manager.enable) ? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "cert-manager"
      "namespace" = var.security.namespace
      "labels" = local.common-labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "cert-manager"
      "options" = local.cert-manager
    }
  }
}

resource "kubernetes_manifest" "letsencrypt" {
  count = ((var.databases.mariadb.enable || var.security.cert-manager.enable) && var.security.letsencrypt.enable)? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns, kubernetes_manifest.cert-manager]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "cert-manager-letsencrypt"
      "namespace" = var.security.namespace
      "labels" = local.common-labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "cert-manager-letsencrypt"
      "options" = local.letsencrypt
    }
  }
}

resource "kubernetes_manifest" "self-sign" {
  count = ((var.databases.mariadb.enable || var.security.cert-manager.enable) && var.security.self-sign.enable)? 1 : 0
  depends_on = [kubernetes_namespace_v1.security-ns, kubernetes_manifest.cert-manager]
  manifest = {
    "apiVersion" = "vynil.solidite.fr/v1"
    "kind"       = "Install"
    "metadata" = {
      "name"      = "cert-manager-self-sign"
      "namespace" = var.security.namespace
      "labels" = local.common-labels
    }
    "spec" = {
      "distrib" = "core"
      "category" = "core"
      "component" = "cert-manager-self-sign"
      "options" = local.self-sign
    }
  }
}
