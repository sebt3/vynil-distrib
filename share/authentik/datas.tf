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
  metadata {
    name      = "authentik"
    namespace = var.namespace
  }
}

data "kustomization_overlay" "data" {
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  images {
    name = "ghcr.io/goauthentik/server"
    new_name = "${var.image.registry}/${var.image.repository}"
    new_tag  = "${var.image.tag}"
  }
  config_map_generator {
    name = var.component
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
      "AUTHENTIK_POSTGRESQL__HOST=${var.instance}-${var.component}.${var.namespace}.svc",
      "AUTHENTIK_POSTGRESQL__NAME=${var.component}",
      "AUTHENTIK_POSTGRESQL__PORT=5432",
      "AUTHENTIK_POSTGRESQL__USER=${var.component}",
      "AUTHENTIK_REDIS__HOST=${var.name}-${var.component}-redis",
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
                      name: ${var.component}.${var.instance}-${var.component}.credentials.postgresql.acid.zalan.do
                      key: password
                envFrom:
                - secretRef:
                    name: ${var.component}
                - configMapRef:
                    name: ${var.component}
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
                      name: ${var.component}.${var.name}-${var.component}.credentials.postgresql.acid.zalan.do
                      key: password
                envFrom:
                - secretRef:
                    name: ${var.component}
                - configMapRef:
                    name: ${var.component}
    EOF
  }
  patches {
    target {
      kind = "ClusterRole"
      name = "authentik-vynil-auth"
    }
    patch = <<-EOF
    - op: replace
      path: /metadata/name
      value: authentik-${var.namespace}
    EOF
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "authentik-vynil-auth"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: authentik-vynil-auth
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: authentik-${var.namespace}
      subjects:
        - kind: ServiceAccount
          name: authentik
          namespace: ${var.namespace}
    EOF
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "authentik-vynil-auth"
    }
    patch = <<-EOF
    - op: replace
      path: /metadata/name
      value: authentik-${var.namespace}
    EOF
  }
}
