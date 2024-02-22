locals {
    annotations = {
      "vynil.solidite.fr/meta" = "core"
      "vynil.solidite.fr/name" = var.namespace
    }
    crd-opentelemetry = { for k, v in var.crds.opentelemetry : k => v if k!="enable" }
    crd-jaeger = { for k, v in var.crds.jaeger : k => v if k!="enable" }
    crd-prometheus = { for k, v in var.crds.prometheus : k => v if k!="enable" }
    crd-k8up = { for k, v in var.crds.k8up : k => v if k!="enable" }
    crd-secret-generator = { for k, v in var.crds.secret-generator : k => v if k!="enable" }
    crd-cert-manager = { for k, v in var.crds.cert-manager : k => v if k!="enable" }
    crd-traefik = { for k, v in var.crds.traefik : k => v if k!="enable" }
    crd-flux = { for k, v in var.crds.flux : k => v if k!="enable" }
    crd-redis = { for k, v in var.crds.redis : k => v if k!="enable" }
    crd-mariadb = { for k, v in var.crds.mariadb : k => v if k!="enable" }
    crd-mysql = { for k, v in var.crds.mysql : k => v if k!="enable" }
    crd-rabbitmq = { for k, v in var.crds.rabbitmq : k => v if k!="enable" }
    crd-mongo = { for k, v in var.crds.mongo : k => v if k!="enable" }
    crd-pg = { for k, v in var.crds.pg : k => v if k!="enable" }
    crd-mayfly = { for k, v in var.crds.mayfly : k => v if k!="enable" }
}

resource "kubectl_manifest" "crd-jmayflyaeger" {
  count = (var.crds.mayfly.enable || var.tools.mayfly.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-mayfly"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "mayfly"
      options: ${jsonencode(local.crd-mayfly)}
  EOF
}

resource "kubectl_manifest" "crd-jaeger" {
  count = (var.crds.jaeger.enable || var.tools.jaeger.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-jaeger"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "jaeger"
      options: ${jsonencode(local.crd-jaeger)}
  EOF
}

resource "kubectl_manifest" "crd-opentelemetry" {
  count = (var.crds.opentelemetry.enable || var.tools.opentelemetry.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-opentelemetry"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "opentelemetry"
      options: ${jsonencode(local.crd-opentelemetry)}
  EOF
}

resource "kubectl_manifest" "crd-prometheus" {
  count = (var.crds.prometheus.enable || var.tools.prometheus.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-prometheus"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "prometheus"
      options: ${jsonencode(local.crd-prometheus)}
  EOF
}

resource "kubectl_manifest" "crd-cert-manager" {
  count = (var.crds.cert-manager.enable || var.security.cert-manager.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-cert-manager"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "cert-manager"
      options: ${jsonencode(local.crd-cert-manager)}
  EOF
}

resource "kubectl_manifest" "crd-secret-generator" {
  count = (var.crds.secret-generator.enable || var.security.secret-generator.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-secret-generator"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "secret-generator"
      options: ${jsonencode(local.crd-cert-manager)}
  EOF
}

resource "kubectl_manifest" "crd-k8up" {
  count = (var.crds.k8up.enable || var.backup.k8up.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-k8up"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "k8up"
      options: ${jsonencode(local.crd-cert-manager)}
  EOF
}

resource "kubectl_manifest" "crd-traefik" {
  count = (var.crds.traefik.enable || var.traefik.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-traefik"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "traefik"
      options: ${jsonencode(local.crd-traefik)}
  EOF
}

resource "kubectl_manifest" "crd-flux" {
  count = (var.crds.flux.enable || var.flux.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-flux"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "flux"
      options: ${jsonencode(local.crd-flux)}
  EOF
}

resource "kubectl_manifest" "crd-redis" {
  count = (var.crds.redis.enable || var.databases.redis.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-redis"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "redis"
      options: ${jsonencode(local.crd-redis)}
  EOF
}

resource "kubectl_manifest" "crd-mariadb" {
  count = (var.crds.mariadb.enable || var.databases.mariadb.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-mariadb"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "mariadb"
      options: ${jsonencode(local.crd-mariadb)}
  EOF
}

resource "kubectl_manifest" "crd-mysql" {
  count = (var.crds.mysql.enable || var.databases.mysql.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-mysql"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "mysql"
      options: ${jsonencode(local.crd-mysql)}
  EOF
}

resource "kubectl_manifest" "crd-rabbitmq" {
  count = (var.crds.rabbitmq.enable || var.databases.rabbitmq.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-rabbitmq"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "rabbitmq"
      options: ${jsonencode(local.crd-rabbitmq)}
  EOF
}

resource "kubectl_manifest" "crd-mongo" {
  count = (var.crds.mongo.enable || var.databases.mongo.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-mongo"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "mongo"
      options: ${jsonencode(local.crd-mongo)}
  EOF
}

resource "kubectl_manifest" "crd-pg" {
  count = (var.crds.pg.enable || var.databases.pg.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-pg"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "crd"
      component: "pg"
      options: ${jsonencode(local.crd-pg)}
  EOF
}
