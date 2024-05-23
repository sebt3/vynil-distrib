resource "kubectl_manifest" "Service_k8up-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: "${var.instance}-${var.component}"
      labels: ${jsonencode(local.k8up_all_labels)}
      namespace: ${var.namespace}
    spec:
      type: ClusterIP
      ports:
      - name: http
        port: 80
        targetPort: http
      selector: ${jsonencode(local.k8up_labels)}
EOF
}

