resource "kubectl_manifest" "Service_pinniped-supervisor-api" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: pinniped-supervisor-api
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      annotations:
        kapp.k14s.io/disable-default-label-scoping-rules: ''
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      type: ClusterIP
      selector:
        deployment.pinniped.dev: supervisor
      ports:
      - protocol: TCP
        port: 443
        targetPort: 10250
EOF
}

