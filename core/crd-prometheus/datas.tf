
data "kustomization_overlay" "data" {
  resources = [
    "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${var.release}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml",
    "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${var.release}/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
  ]
}
