
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [
    "https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${var.release}/deploy/role.yaml",
    "https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${var.release}/deploy/role_binding.yaml",
    "https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${var.release}/deploy/service_account.yaml",
    "https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${var.release}/deploy/operator.yaml",
  ]
  images {
    name = "quay.io/mittwald/kubernetes-secret-generator"
    new_name = "${var.image.registry}/${var.image.repository}"
    new_tag = "${var.image.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "kubernetes-secret-generator"
    }
    patch = <<-EOF
    - op: remove
      path: /spec/template/spec/containers/0/env/0/valueFrom
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "kubernetes-secret-generator"
    }
    patch = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kubernetes-secret-generator
    spec:
      template:
        spec:
          containers:
          - name: kubernetes-secret-generator
            env:
            - name: WATCH_NAMESPACE
              value: "${var.namespaces}"
            - name: SECRET_LENGTH
              value: "${var.secret_length}"
    EOF
  }
}
