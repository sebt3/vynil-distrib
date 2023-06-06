data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
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
