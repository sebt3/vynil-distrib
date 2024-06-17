resource "kubectl_manifest" "MutatingWebhookConfiguration_hnc-mutating-webhook-configuration" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: MutatingWebhookConfiguration
    metadata:
      name: hnc-mutating-webhook-configuration
      labels: ${jsonencode(local.common_labels)}
      annotations:
        cert-manager.io/inject-ca-from: ${var.namespace}/hnc-serving-cert
    webhooks:
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /mutate-namespace
      failurePolicy: Ignore
      name: namespacelabel.hnc.x-k8s.io
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        - UPDATE
        resources:
        - namespaces
      sideEffects: None
EOF
}

