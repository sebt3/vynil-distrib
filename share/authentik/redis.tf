resource "kubernetes_manifest" "authentik_redis" {
  manifest = {
    "apiVersion" = "redis.redis.opstreelabs.in/v1beta1"
    "kind"       = "Redis"
    "metadata"   = {
      "name"      = "${var.name}-${var.component}-redis"
      "namespace" = var.namespace
      "labels"    = local.common-labels
    }
    "spec" = {
      "kubernetesConfig" = {
        "image"           = var.redis.image
        "imagePullPolicy" = "IfNotPresent"
        "redisSecret"     = {
          "name" = var.component
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
