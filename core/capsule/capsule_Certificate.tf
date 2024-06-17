resource "kubectl_manifest" "Certificate_capsule-webhook-cert" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: capsule-webhook-cert
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      dnsNames:
      - capsule-webhook-service.${var.namespace}.svc
      - capsule-webhook-service.${var.namespace}.svc.cluster.local
      issuerRef:
        kind: Issuer
        name: capsule-webhook-selfsigned
      secretName: capsule-tls
      subject:
        organizations:
        - clastix.io
EOF
}

