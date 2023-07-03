locals {
  redis-labels = merge(local.common-labels, {
    "app.kubernetes.io/component" = "redis"
  })
}
resourresource "kubectl_manifest" "dolibarr_redis" {
  yaml_body  = <<-EOF
    apiVersion: "redis.redis.opstreelabs.in/v1beta1"
    kind: "Redis"
    metadata:
      name: "${var.instance}-${var.component}-redis"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.redis-labels)}
    spec:
      kubernetesConfig:
        image: "${var.redis.image}"
        imagePullPolicy: "IfNotPresent"
      storage:
        volumeClaimTemplate:
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: "${var.redis.storage}"
      redisExporter:
        enabled: ${var.redis.exporter.enabled}
        image: "${var.redis.exporter.image}"
      securityContext:
        runAsUser: 1000
        fsGroup: 1000
  EOF
}
