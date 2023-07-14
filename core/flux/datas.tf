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
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
}
