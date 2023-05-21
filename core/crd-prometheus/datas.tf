
data "kustomization_overlay" "data" {
  resources = [
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-alertmanagerconfigs.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-alertmanagers.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-podmonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-probes.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-prometheusagents.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-prometheuses.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-prometheusrules.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-servicemonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/prometheus-operator-crds-${var.release}/charts/prometheus-operator-crds/templates/crd-thanosrulers.yaml",
  ]
}
