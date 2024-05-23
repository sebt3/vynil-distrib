locals {
  core_labels = {
    "app.kubernetes.io/name" = var.component
    "app.kubernetes.io/instance" = var.instance
  }
  common_labels = merge({
    "vynil.solidite.fr/owner-name" = var.instance
    "vynil.solidite.fr/owner-namespace" = var.namespace
    "vynil.solidite.fr/owner-category" = var.category
    "vynil.solidite.fr/owner-component" = var.component
    "app.kubernetes.io/managed-by" = "vynil"
  },local.core_labels)
  traefik_labels = merge({
    "app.kubernetes.io/componant" = "traefik"
  },local.core_labels)
  traefik_all_labels = merge({
    "app.kubernetes.io/componant" = "traefik"
  },local.common_labels)
  common-labels = local.common_labels
}

data "kustomization_overlay" "data" {
  namespace = var.namespace
  common_labels = local.common_labels
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "Service"
      name = "traefik"
    }
    patch = <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: traefik
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ipFamilyPolicy: PreferDualStack
    EOF
  }
}
