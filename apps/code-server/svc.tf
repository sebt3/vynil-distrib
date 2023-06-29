resource "kubectl_manifest" "service" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      type: ClusterIP
      ports:
      - name: http
        port: 80
        protocol: TCP
        targetPort: http
      selector: ${jsonencode(local.common-labels)}
  EOF
}
