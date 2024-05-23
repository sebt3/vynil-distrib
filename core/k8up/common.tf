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
  k8up_labels = merge({
    "app.kubernetes.io/componant" = var.component
  },local.core_labels)
  k8up_all_labels = merge({
    "app.kubernetes.io/componant" = var.component
  },local.common_labels)
}
