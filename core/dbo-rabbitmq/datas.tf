data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [
    "https://github.com/rabbitmq/cluster-operator/releases/v${var.release}/download/cluster-operator.yml",
  ]
  patches {
    target {
      kind = "Deployment"
      name = "rabbitmq-cluster-operator"
    }
    patch = <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rabbitmq-cluster-operator
spec:
    spec:
      containers:
      - name: operator
        image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
    EOF
  }
  patches {
    target {
      kind = "CustomResourceDefinition"
      name = "rabbitmqclusters.rabbitmq.com"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: apiextensions.k8s.io/v1
  kind: CustomResourceDefinition
  metadata:
    name: rabbitmqclusters.rabbitmq.com
    EOF
  }
  patches {
    target {
      kind = "Namespace"
      name = "rabbitmq-system"
    }
    patch = <<-EOF
  $patch: delete
  apiVersion: v1
  kind: Namespace
  metadata:
    name: rabbitmq-system
    EOF
  }
}
