resource "kubectl_manifest" "Service_hnc-webhook-service" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: hnc-webhook-service
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    spec:
      ports:
      - port: 443
        targetPort: 9443
      selector:
        control-plane: controller-manager
EOF
}

resource "kubectl_manifest" "Service_hnc-controller-manager-metrics-service" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        prometheus.io/port: '8080'
        prometheus.io/scheme: http
        prometheus.io/scrape: 'true'
      labels: ${jsonencode(local.common_labels)}
      name: hnc-controller-manager-metrics-service
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - name: metrics
        port: 8080
        targetPort: metrics
      selector:
        control-plane: controller-manager
EOF
}

