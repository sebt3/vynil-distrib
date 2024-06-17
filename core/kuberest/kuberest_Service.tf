resource "kubectl_manifest" "Service_kuberest" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: kuberest
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - name: http
        port: 80
        protocol: TCP
        targetPort: 8080
      selector: ${jsonencode(local.selector)}
      type: ClusterIP
EOF
}

