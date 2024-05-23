resource "kubectl_manifest" "svc" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: "${var.instance}-${var.component}"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.topology_all_labels)}
    spec:
      ports:
      - port: 443
        targetPort: 9443
      selector: ${jsonencode(local.topology_labels)}
EOF
}

