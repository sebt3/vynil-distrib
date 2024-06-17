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
  cleanup_labels = merge({
    "app.kubernetes.io/componant" = "cleanup-controller"
  },local.core_labels)
  cleanup_all_labels = merge({
    "app.kubernetes.io/componant" = "cleanup-controller"
  },local.common_labels)
  admission_labels = merge({
    "app.kubernetes.io/componant" = "admission-controller"
  },local.core_labels)
  admission_all_labels = merge({
    "app.kubernetes.io/componant" = "admission-controller"
  },local.common_labels)
  reports_labels = merge({
    "app.kubernetes.io/componant" = "reports-controller"
  },local.core_labels)
  reports_all_labels = merge({
    "app.kubernetes.io/componant" = "reports-controller"
  },local.common_labels)
  background_labels = merge({
    "app.kubernetes.io/componant" = "background-controller"
  },local.core_labels)
  background_all_labels = merge({
    "app.kubernetes.io/componant" = "background-controller"
  },local.common_labels)
  kyverno_labels = merge({
    "app.kubernetes.io/componant" = "kyverno"
  },local.core_labels)
  kyverno_all_labels = merge({
    "app.kubernetes.io/componant" = "kyverno"
  },local.common_labels)
}
