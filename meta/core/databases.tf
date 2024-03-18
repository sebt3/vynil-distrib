locals {
    postgresql = { for k, v in var.databases.postgresql : k => v if k!="enable" }
    redis = { for k, v in var.databases.redis : k => v if k!="enable" }
    rabbitmq = { for k, v in var.databases.rabbitmq : k => v if k!="enable" }
    mariadb = { for k, v in var.databases.mariadb : k => v if k!="enable" }
    mysql = { for k, v in var.databases.mysql : k => v if k!="enable" }
    mongo = { for k, v in var.databases.mongo : k => v if k!="enable" }
    pg = { for k, v in var.databases.pg : k => v if k!="enable" }
}

resource "kubernetes_namespace_v1" "databases-ns" {
  count = ( var.databases.postgresql.enable || var.databases.redis.enable || var.databases.rabbitmq.enable || var.databases.mariadb.enable || var.databases.mysql.enable || var.databases.mongo.enable || var.databases.pg.enable )? 1 : 0
  metadata {
    annotations = local.annotations
    labels = local.common-labels
    name = var.databases.namespace
  }
}

resource "kubectl_manifest" "dbo-postgresql" {
  count = var.databases.postgresql.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-postgresql"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "postgresql"
      options: ${jsonencode(local.postgresql)}
  EOF
}

resource "kubectl_manifest" "dbo-redis" {
  count = var.databases.redis.enable ? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns,kubectl_manifest.crd-redis]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-redis"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "redis"
      options: ${jsonencode(local.redis)}
  EOF
}

resource "kubectl_manifest" "rabbitmq" {
  count = var.databases.rabbitmq.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-rabbitmq"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "rabbitmq"
      options: ${jsonencode(local.letsencrypt)}
  EOF
}

resource "kubectl_manifest" "mariadb" {
  count = var.databases.mariadb.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns, kubectl_manifest.crd-prometheus, kubectl_manifest.crd-mariadb]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-mariadb"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "mariadb"
      options: ${jsonencode(local.mariadb)}
  EOF
}

resource "kubectl_manifest" "mysql" {
  count = var.databases.mysql.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns, kubectl_manifest.crd-mysql]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-mysql"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "mysql"
      options: ${jsonencode(local.mysql)}
  EOF
}

resource "kubectl_manifest" "mongo" {
  count = var.databases.mongo.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns, kubectl_manifest.crd-mongo]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-mongo"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "mongo"
      options: ${jsonencode(local.mongo)}
  EOF
}

resource "kubectl_manifest" "pg" {
  count = var.databases.pg.enable? 1 : 0
  depends_on = [kubernetes_namespace_v1.databases-ns, kubectl_manifest.crd-pg]
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "dbo-pg"
      namespace: "${var.databases.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "${var.component}"
      category: "dbo"
      component: "pg"
      options: ${jsonencode(local.pg)}
  EOF
}
