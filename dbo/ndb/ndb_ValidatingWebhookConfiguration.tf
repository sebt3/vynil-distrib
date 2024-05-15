resource "kubectl_manifest" "vwc" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: ${var.namespace}-${var.instance}-${var.component}
      labels: ${jsonencode(local.webhook_labels)}
    webhooks:
    - clientConfig:
        service:
          name: ${kubectl_manifest.webhook_service.name}
          namespace: ${var.namespace}
          path: /ndb/validate
          port: 9443
      failurePolicy: Fail
      name: validating-webhook.ndbcluster.mysql.oracle.com
      rules:
      - apiGroups:
        - mysql.oracle.com
        apiVersions:
        - v1
        operations:
        - CREATE
        - UPDATE
        resources:
        - ndbclusters
      admissionReviewVersions:
      - v1
      sideEffects: None
EOF
}

