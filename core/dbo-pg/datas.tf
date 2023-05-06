
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [
    "https://raw.githubusercontent.com/zalando/postgres-operator/v${var.release}/manifests/api-service.yaml",
    "https://raw.githubusercontent.com/zalando/postgres-operator/v${var.release}/manifests/postgres-operator.yaml",
    "https://raw.githubusercontent.com/zalando/postgres-operator/v${var.release}/manifests/operator-service-account-rbac.yaml",
    "https://raw.githubusercontent.com/zalando/postgres-operator/v${var.release}/manifests/configmap.yaml",
  ]
  patches {
    target {
      kind = "Deployment"
      name = "postgres-operator"
    }
    patch = <<-EOF
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: postgres-operator
  spec:
    template:
      spec:
        containers:
        - name: postgres-operator
          image: "${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}"
    EOF
  }
  patches {
    target {
      kind = "ConfigMap"
      name = "postgres-operator"
    }
    patch = <<-EOF
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: postgres-operator
  data:
    connection_pooler_image: "${var.images.connectionPooler.registry}/${var.images.connectionPooler.repository}:${var.images.connectionPooler.tag}"
    docker_image: "${var.images.spilo.registry}/${var.images.spilo.repository}:${var.images.spilo.tag}"
    logical_backup_docker_image: "${var.images.logicalBackup.registry}/${var.images.logicalBackup.repository}:${var.images.logicalBackup.tag}"
    EOF
  }
}
