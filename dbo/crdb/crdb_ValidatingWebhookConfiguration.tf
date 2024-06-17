resource "kubectl_manifest" "ValidatingWebhookConfiguration_cockroach-operator-validating-webhook-configuration" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: cockroach-operator-validating-webhook-configuration
      labels: ${jsonencode(local.common_labels)}
    webhooks:
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          path: /validate-crdb-cockroachlabs-com-v1alpha1-crdbcluster
      failurePolicy: Fail
      name: vcrdbcluster.kb.io
      rules:
      - apiGroups:
        - crdb.cockroachlabs.com
        apiVersions:
        - v1alpha1
        operations:
        - CREATE
        - UPDATE
        resources:
        - crdbclusters
      sideEffects: None
EOF
}

