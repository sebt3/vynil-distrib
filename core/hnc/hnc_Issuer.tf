resource "kubectl_manifest" "Issuer_hnc-selfsigned-issuer" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: hnc-selfsigned-issuer
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    spec:
      selfSigned: {}
EOF
}

