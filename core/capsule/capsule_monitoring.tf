resource "kubectl_manifest" "ServiceMonitor_capsule-monitor" {
  yaml_body  = <<-EOF
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: capsule-monitor
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      endpoints:
      - interval: 15s
        port: metrics
        path: /metrics
      jobLabel: app.kubernetes.io/name
      selector:
        matchLabels: ${jsonencode(local.selector)}
      namespaceSelector:
        matchNames:
        - ${var.namespace}
EOF
}

