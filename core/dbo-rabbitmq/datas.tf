
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [
    "https://github.com/rabbitmq/cluster-operator//config/rbac/?ref=v${var.release}",
    "https://github.com/rabbitmq/cluster-operator//config/manager/?ref=v${var.release}"
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
}
