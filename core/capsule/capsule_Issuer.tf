resource "kubectl_manifest" "Issuer_capsule-webhook-selfsigned" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: capsule-webhook-selfsigned
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      selfSigned: {}
EOF
}

