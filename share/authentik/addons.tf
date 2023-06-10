locals {
    labels = {
      "vynil.solidite.fr/owner-namespace" = var.namespace
      "vynil.solidite.fr/owner-category" = "share"
      "vynil.solidite.fr/owner-component" = "authentik"
      "app.kubernetes.io/managed-by" = "vynil"
      "app.kubernetes.io/name" = "authentik"
      "app.kubernetes.io/instance" = var.name
      "app.kubernetes.io/version" = var.image.tag
    }
    app-name  = "authentik"
    dns-names = ["${var.sub-domain}.${var.domain-name}"]
    middlewares = [{"name" = "${local.app-name}-https"}]
    services = [{
      "kind" = "Service"
      "name" = local.app-name
      "namespace" = var.namespace
      "port" = 80
    }]
    routes = [ for v in local.dns-names : {
      "kind" = "Route"
      "match" = "Host(`${v}`)"
      "middlewares" = local.middlewares
      "services" = local.services
    }]
}

resource "kubernetes_manifest" "authentik_secret" {
  manifest = {
    "apiVersion" = "secretgenerator.mittwald.de/v1alpha1"
    "kind"       = "StringSecret"
    "metadata" = {
      "name"      = local.app-name
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
      "forceRegenerate" = false,
      "fields" = [
        {
          "fieldName" = "AUTHENTIK_SECRET_KEY"
          "length"    = "128"
        },
        {
          "fieldName" = "AUTHENTIK_BOOTSTRAP_PASSWORD"
          "length"    = "32"
        },
        {
          "fieldName" = "AUTHENTIK_BOOTSTRAP_TOKEN"
          "length"    = "64"
        },
        {
          "fieldName" = "AUTHENTIK_REDIS__PASSWORD"
          "length"    = "32"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "authentik_postgresql" {
  manifest = {
    "apiVersion" = "acid.zalan.do/v1"
    "kind"       = "postgresql"
    "metadata" = {
      "name"      = "${var.name}-${local.app-name}"
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
      "databases" = {
        "${local.app-name}" = "${local.app-name}"
      }
      "numberOfInstances" = var.postgres.replicas
      "podAnnotations" = {
        "k8up.io/backupcommand" = "pg_dump -U postgres -d ${local.app-name} --clean"
        "k8up.io/file-extension" = ".sql"
      }
      "postgresql" = {
        "version" = var.postgres.version
      }
      "teamId" = var.name
      "users" = {
        "${local.app-name}" = [
          "superuser",
          "createdb"
        ]
      }
      "volume" = {
        "size" = var.postgres.storage
      }
    }
  }
}

resource "kubernetes_manifest" "authentik_redis" {
  manifest = {
    "apiVersion" = "redis.redis.opstreelabs.in/v1beta1"
    "kind"       = "Redis"
    "metadata"   = {
      "name"      = "${var.name}-${local.app-name}-redis"
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
      "kubernetesConfig" = {
        "image"           = var.redis.image
        "imagePullPolicy" = "IfNotPresent"
        "redisSecret"     = {
          "name" = local.app-name
          "key"  = "AUTHENTIK_REDIS__PASSWORD"
        }
      }
      "storage" = {
        "volumeClaimTemplate" = {
          "spec" = {
            "accessModes" = ["ReadWriteOnce"]
            "resources"   = {
              "requests" = {
                "storage" = var.redis.storage
              }
            }
          }
        }
      }
      "redisExporter" = {
        "enabled" = var.redis.exporter.enabled
        "image" = var.redis.exporter.image
      }
      "securityContext" = {
        "runAsUser" = 1000
        "fsGroup" = 1000
      }
    }
  }
}

resource "kubernetes_manifest" "authentik_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata"   = {
      "name"      = local.app-name
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
        "secretName" = "${local.app-name}-cert"
        "dnsNames"   = local.dns-names
        "issuerRef"  = {
          "name"  = var.issuer
          "kind"  = "ClusterIssuer"
          "group" = "cert-manager.io"
        }
    }
  }
}

resource "kubernetes_manifest" "authentik_https_redirect" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "${local.app-name}-https"
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
      "secretName" = "${local.app-name}-cert"
      "issuerRef"  = {
        "name"  = "${var.issuer}"
        "kind"  = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }
}

resource "kubernetes_manifest" "authentik_ingress" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = local.app-name
      "namespace" = var.namespace
      "labels"    = local.labels
      "annotations" = {
        "kubernetes.io/ingress.class" = var.ingress-class
      }
    }
    "spec" = {
      "entryPoints" = ["web","websecure"]
      "routes" = local.routes
      "tls" = {
        "secretName" = "${local.app-name}-cert"
      }
    }
  }
}
