locals {
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
    crd-mysql = { for k, v in var.crds.mysql : k => v if k!="enable" }
    crd-rabbitmq = { for k, v in var.crds.rabbitmq : k => v if k!="enable" }
    crd-mongo = { for k, v in var.crds.mongo : k => v if k!="enable" }
    crd-pg = { for k, v in var.crds.pg : k => v if k!="enable" }
    crd-ndb = { for k, v in var.crds.ndb : k => v if k!="enable" }
    crd-mayfly = { for k, v in var.crds.mayfly : k => v if k!="enable" }
    crd-hnc = { for k, v in var.crds.hnc : k => v if k!="enable" }
    crd-kyverno = { for k, v in var.crds.kyverno : k => v if k!="enable" }
    crd-kuberest = { for k, v in var.crds.kuberest : k => v if k!="enable" }
}

resource "kubectl_manifest" "crd-kuberest" {
  count = (var.crds.kuberest.enable || var.tools.kuberest.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-kuberest"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "crd"
      component: "kuberest"
      options: ${jsonencode(local.crd-kuberest)}
  EOF
}

resource "kubectl_manifest" "crd-kyverno" {
  count = (var.crds.kyverno.enable || var.security.kyverno.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-kyverno"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "crd"
      component: "kyverno"
      options: ${jsonencode(local.crd-kyverno)}
  EOF
}

resource "kubectl_manifest" "crd-hnc" {
  count = (var.crds.hnc.enable || var.security.hnc.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-hnc"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "crd"
      component: "hnc"
      options: ${jsonencode(local.crd-hnc)}
  EOF
}

resource "kubectl_manifest" "crd-mayfly" {
  count = (var.crds.mayfly.enable || var.tools.mayfly.enable) ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-mayfly"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "crd"
      component: "mayfly"
      options: ${jsonencode(local.crd-mayfly)}
  EOF
}

resource "kubectl_manifest" "crd-prometheus" {
  count = (var.crds.prometheus.enable) ? 1 : 0
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
      category: "crd"
      component: "traefik"
      options: ${jsonencode(local.crd-traefik)}
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
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
      distrib: "${var.component}"
      category: "crd"
      component: "pg"
      options: ${jsonencode(local.crd-pg)}
  EOF
}

resource "kubectl_manifest" "crd-ndb" {
  count = (var.crds.ndb.enable || var.databases.ndb.enable)? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "crd-ndb"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "crd"
      component: "ndb"
      options: ${jsonencode(local.crd-ndb)}
  EOF
}
