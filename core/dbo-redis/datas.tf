
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = concat([
    "https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${var.release}/charts/redis-operator/crds/redis-cluster.yaml",
    "https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${var.release}/charts/redis-operator/crds/redis-replication.yaml",
    "https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${var.release}/charts/redis-operator/crds/redis-sentinel.yaml",
    "https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${var.release}/charts/redis-operator/crds/redis.yaml"
  ],[ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"])
  patches {
    target {
      kind = "Deployment"
      name = "redis-operator"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: redis-operator
        namespace: dbo-redis
      spec:
        template:
          spec:
            containers:
            - name: "redis-operator"
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
              resources:
                limits:
                  cpu: "${var.resources.limits.cpu}"
                  memory: "${var.resources.limits.memory}"
                requests:
                  cpu: "${var.resources.requests.cpu}"
                  memory: "${var.resources.requests.memory}"
    EOF
  }
}
