resource "kubectl_manifest" "svc" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: cockroach-operator-webhook-service
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 443
        targetPort: 9443
      selector: ${jsonencode(local.selector)}
EOF
}

