resource "kubectl_manifest" "ConfigMap_pinniped-supervisor-static-config" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: pinniped-supervisor-static-config
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    data:
      pinniped.yaml: |-
        apiGroupSuffix: pinniped.dev
        names:
          defaultTLSCertificateSecret: pinniped-supervisor-default-tls-certificate
          apiService: pinniped-supervisor-api
        labels:
          app: pinniped-supervisor
        tls:
          onedottwo:
            allowedCiphers: []
EOF
}

