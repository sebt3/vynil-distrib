resource "kubectl_manifest" "Certificate_hnc-serving-cert" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: hnc-serving-cert
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    spec:
      commonName: hnc-webhook-service.${var.namespace}.svc
      dnsNames:
      - hnc-webhook-service.${var.namespace}.svc.cluster.local
      - hnc-webhook-service.${var.namespace}.svc
      issuerRef:
        kind: Issuer
        name: hnc-selfsigned-issuer
      secretName: webhook-server-cert
EOF
}

