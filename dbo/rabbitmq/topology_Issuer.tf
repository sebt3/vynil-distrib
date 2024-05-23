resource "kubectl_manifest" "issuer" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: "${var.instance}-${var.component}"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.topology_all_labels)}
    spec:
      selfSigned: {}
EOF
}

