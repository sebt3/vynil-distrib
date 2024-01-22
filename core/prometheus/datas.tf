
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
  rb-patch = <<-EOF
    - op: replace
      path: /subjects/0/namespace
      value: "${var.namespace}"
    EOF

}
data "kustomization_overlay" "data" {
  common_labels = local.common-labels
  namespace = var.namespace
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))<1 && length(regexall("WebhookConfiguration",file))<1]
  images {
    name = "quay.io/prometheus-operator/prometheus-operator"
    new_name = "${var.images.operator.registry}/${var.images.operator.repository}"
    new_tag = "${var.images.operator.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "prometheus-community-kube-operator"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/template/spec/0/imagePullPolicy
      value: "${var.images.operator.pullPolicy}"
    EOF
  }
  patches {
    target {
      kind = "ServiceMonitor"
      name = "prometheus-community-kube-operator"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/namespaceSelector/matchNames/0
      value: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "Certificate"
      name = "prometheus-community-kube-admission"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/dnsNames/1
      value: "prometheus-community-kube-operator.${var.namespace}.svc"
    EOF
  }
  patches {
    target {
      kind = "PrometheusRule"
      name = "prometheus-community-kube-prometheus-operator"
    }
    patch = <<-EOF
      apiVersion: monitoring.coreos.com/v1
      kind: PrometheusRule
      metadata:
        name: prometheus-community-kube-prometheus-operator
      spec:
        groups:
        - name: prometheus-operator
          rules:
          - alert: PrometheusOperatorListErrors
            annotations:
              description: Errors while performing List operations in controller {{$labels.controller}} in {{$labels.namespace}} namespace.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorlisterrors
              summary: Errors while performing list operations in controller.
            expr: (sum by (cluster,controller,namespace) (rate(prometheus_operator_list_operations_failed_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[10m])) / sum by (cluster,controller,namespace) (rate(prometheus_operator_list_operations_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[10m]))) > 0.4
            for: 15m
            labels:
              severity: warning
          - alert: PrometheusOperatorWatchErrors
            annotations:
              description: Errors while performing watch operations in controller {{$labels.controller}} in {{$labels.namespace}} namespace.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorwatcherrors
              summary: Errors while performing watch operations in controller.
            expr: (sum by (cluster,controller,namespace) (rate(prometheus_operator_watch_operations_failed_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m])) / sum by (cluster,controller,namespace) (rate(prometheus_operator_watch_operations_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]))) > 0.4
            for: 15m
            labels:
              severity: warning
          - alert: PrometheusOperatorSyncFailed
            annotations:
              description: Controller {{ $labels.controller }} in {{ $labels.namespace }} namespace fails to reconcile {{ $value }} objects.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorsyncfailed
              summary: Last controller reconciliation failed
            expr: min_over_time(prometheus_operator_syncs{status="failed",job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]) > 0
            for: 10m
            labels:
              severity: warning
          - alert: PrometheusOperatorReconcileErrors
            annotations:
              description: '{{ $value | humanizePercentage }} of reconciling operations failed for {{ $labels.controller }} controller in {{ $labels.namespace }} namespace.'
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorreconcileerrors
              summary: Errors while reconciling objects.
            expr: (sum by (cluster,controller,namespace) (rate(prometheus_operator_reconcile_errors_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]))) / (sum by (cluster,controller,namespace) (rate(prometheus_operator_reconcile_operations_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]))) > 0.1
            for: 10m
            labels:
              severity: warning
          - alert: PrometheusOperatorStatusUpdateErrors
            annotations:
              description: '{{ $value | humanizePercentage }} of status update operations failed for {{ $labels.controller }} controller in {{ $labels.namespace }} namespace.'
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorstatusupdateerrors
              summary: Errors while updating objects status.
            expr: (sum by (cluster,controller,namespace) (rate(prometheus_operator_status_update_errors_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]))) / (sum by (cluster,controller,namespace) (rate(prometheus_operator_status_update_operations_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]))) > 0.1
            for: 10m
            labels:
              severity: warning
          - alert: PrometheusOperatorNodeLookupErrors
            annotations:
              description: Errors while reconciling Prometheus in {{ $labels.namespace }} Namespace.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatornodelookuperrors
              summary: Errors while reconciling Prometheus.
            expr: rate(prometheus_operator_node_address_lookup_errors_total{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]) > 0.1
            for: 10m
            labels:
              severity: warning
          - alert: PrometheusOperatorNotReady
            annotations:
              description: Prometheus operator in {{ $labels.namespace }} namespace isn't ready to reconcile {{ $labels.controller }} resources.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatornotready
              summary: Prometheus operator not ready
            expr: min by (cluster,controller,namespace) (max_over_time(prometheus_operator_ready{job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]) == 0)
            for: 5m
            labels:
              severity: warning
          - alert: PrometheusOperatorRejectedResources
            annotations:
              description: Prometheus operator in {{ $labels.namespace }} namespace rejected {{ printf "%0.0f" $value }} {{ $labels.controller }}/{{ $labels.resource }} resources.
              runbook_url: https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorrejectedresources
              summary: Resources rejected by Prometheus operator
            expr: min_over_time(prometheus_operator_managed_resources{state="rejected",job="prometheus-community-kube-operator",namespace="${var.namespace}"}[5m]) > 0
            for: 5m
            labels:
              severity: warning
    EOF
  }

}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]

  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "prometheus-community-kube-operator"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "prometheus-community-kube-admission"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "prometheus-community-kube-admission"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    EOF
  }
}


