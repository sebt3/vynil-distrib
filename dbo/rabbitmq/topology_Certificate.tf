resource "kubectl_manifest" "cert" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: "${var.instance}-${var.component}-cert"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.topology_all_labels)}
    spec:
      dnsNames:
      - ${kubectl_manifest.svc.name}.${var.namespace}.svc
      - ${kubectl_manifest.svc.name}.${var.namespace}.svc.cluster.local
      issuerRef:
        kind: Issuer
        name: ${kubectl_manifest.issuer.name}
      secretName: ${var.instance}-${var.component}-cert
EOF
}

