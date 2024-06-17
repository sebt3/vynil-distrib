resource "kubectl_manifest" "ValidatingWebhookConfiguration_hnc-validating-webhook-configuration" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      annotations:
        cert-manager.io/inject-ca-from: ${var.namespace}/hnc-serving-cert
      name: hnc-validating-webhook-configuration
      labels: ${jsonencode(local.common_labels)}
    webhooks:
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /validate-hnc-x-k8s-io-v1alpha2-subnamespaceanchors
      failurePolicy: Fail
      name: subnamespaceanchors.hnc.x-k8s.io
      rules:
      - apiGroups:
        - hnc.x-k8s.io
        apiVersions:
        - v1alpha2
        operations:
        - CREATE
        - UPDATE
        - DELETE
        resources:
        - subnamespaceanchors
      sideEffects: None
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /validate-hnc-x-k8s-io-v1alpha2-hierarchyconfigurations
      failurePolicy: Fail
      name: hierarchyconfigurations.hnc.x-k8s.io
      rules:
      - apiGroups:
        - hnc.x-k8s.io
        apiVersions:
        - v1alpha2
        operations:
        - CREATE
        - UPDATE
        resources:
        - hierarchyconfigurations
      sideEffects: None
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /validate-objects
      failurePolicy: Fail
      name: objects.hnc.x-k8s.io
      namespaceSelector:
        matchLabels:
          hnc.x-k8s.io/included-namespace: 'true'
      rules:
      - apiGroups:
        - '*'
        apiVersions:
        - '*'
        operations:
        - CREATE
        - UPDATE
        - DELETE
        resources:
        - '*'
        scope: Namespaced
      sideEffects: None
      timeoutSeconds: 2
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /validate-hnc-x-k8s-io-v1alpha2-hncconfigurations
      failurePolicy: Fail
      name: hncconfigurations.hnc.x-k8s.io
      rules:
      - apiGroups:
        - hnc.x-k8s.io
        apiVersions:
        - v1alpha2
        operations:
        - CREATE
        - UPDATE
        - DELETE
        resources:
        - hncconfigurations
      sideEffects: None
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: hnc-webhook-service
          namespace: ${var.namespace}
          path: /validate-v1-namespace
      failurePolicy: Fail
      name: namespaces.hnc.x-k8s.io
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - DELETE
        - CREATE
        - UPDATE
        resources:
        - namespaces
      sideEffects: None
EOF
}

