locals {
  common-labels = {
    "vynil.solidite.fr/owner-name" = var.instance
    "vynil.solidite.fr/owner-namespace" = var.namespace
    "vynil.solidite.fr/owner-category" = var.category
    "vynil.solidite.fr/owner-component" = var.component
    "app.kubernetes.io/managed-by" = "vynil"
    "app.kubernetes.io/name" = var.component
    "app.kubernetes.io/instance" = var.instance
  }
}

data "kubernetes_secret_v1" "authentik" {
  depends_on = [kubernetes_manifest.authentik_secret]
  metadata {
    name      = var.component
    namespace = var.namespace
  }
}

data "kustomization_overlay" "data" {
  depends_on = [kubernetes_manifest.authentik_secret]
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  images {
    name = "ghcr.io/goauthentik/server"
    new_name = "${var.image.registry}/${var.image.repository}"
    new_tag  = "${var.image.tag}"
  }
  config_map_generator {
    name = local.app-name
    behavior = "create"
    literals = [
      "AUTHENTIK_EMAIL__PORT=${var.email.port}",
      "AUTHENTIK_EMAIL__TIMEOUT=${var.email.timeout}",
      "AUTHENTIK_EMAIL__USE_TLS=${var.email.use_tls}",
      "AUTHENTIK_EMAIL__USE_SSL=${var.email.use_ssl}",
      "AUTHENTIK_ERROR_REPORTING__ENABLED=${var.error_reporting.enabled}",
      "AUTHENTIK_ERROR_REPORTING__ENVIRONMENT=${var.error_reporting.environment}",
      "AUTHENTIK_ERROR_REPORTING__SEND_PII=${var.error_reporting.send_pii}",
      "AUTHENTIK_GEOIP=${var.geoip}",
      "AUTHENTIK_LOG_LEVEL=${var.loglevel}",
      "AUTHENTIK_OUTPOSTS__CONTAINER_IMAGE_BASE=${var.image.registry}/${var.image.project}/%(type)s:%(version)s",
      "AUTHENTIK_POSTGRESQL__HOST=${var.name}-${local.app-name}.${var.namespace}.svc",
      "AUTHENTIK_POSTGRESQL__NAME=${local.app-name}",
      "AUTHENTIK_POSTGRESQL__PORT=5432",
      "AUTHENTIK_POSTGRESQL__USER=${local.app-name}",
      "AUTHENTIK_REDIS__HOST=${var.name}-${local.app-name}-redis",
      "AUTHENTIK_BOOTSTRAP_EMAIL=${var.admin.email}@${var.domain-name}",
    ]
  }
  patches {
    target {
      kind = "Deployment"
      name = "authentik-server"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: authentik-server
      spec:
        template:
          spec:
            containers:
              - name: authentik
                image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
                imagePullPolicy: "${var.image.pullPolicy}"
                env:
                - name: AUTHENTIK_POSTGRESQL__PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: ${local.app-name}.${var.name}-${local.app-name}.credentials.postgresql.acid.zalan.do
                      key: password
                envFrom:
                - secretRef:
                    name: ${local.app-name}
                - configMapRef:
                    name: ${local.app-name}
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "authentik-worker"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: authentik-worker
      spec:
        template:
          spec:
            containers:
              - name: authentik
                image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
                imagePullPolicy: "${var.image.pullPolicy}"
                env:
                - name: AUTHENTIK_POSTGRESQL__PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: ${local.app-name}.${var.name}-${local.app-name}.credentials.postgresql.acid.zalan.do
                      key: password
                envFrom:
                - secretRef:
                    name: ${local.app-name}
                - configMapRef:
                    name: ${local.app-name}
    EOF
  }
}
