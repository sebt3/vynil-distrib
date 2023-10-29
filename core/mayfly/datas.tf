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

data "kustomization_overlay" "data" {
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "Deployment"
      name = "mayfly"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: mayfly
      spec:
        template:
          spec:
            containers:
            - name: manager
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
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
        name: mayfly
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: mayfly
      subjects:
        - kind: ServiceAccount
          name: mayfly
          namespace: ${var.namespace}
    EOF
  }
}
