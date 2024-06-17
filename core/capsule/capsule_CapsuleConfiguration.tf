resource "kubectl_manifest" "CapsuleConfiguration_default" {
  yaml_body  = <<-EOF
    apiVersion: capsule.clastix.io/v1beta2
    kind: CapsuleConfiguration
    metadata:
      name: default
      labels: ${jsonencode(local.common_labels)}
    spec:
      enableTLSReconciler: false
      overrides:
        mutatingWebhookConfigurationName: capsule-mutating-webhook-configuration
        TLSSecretName: capsule-tls
        validatingWebhookConfigurationName: capsule-validating-webhook-configuration
      forceTenantPrefix: true
      userGroups:
      - projectcapsule.dev
      protectedNamespaceRegex: ''
      nodeMetadata:
        forbiddenAnnotations:
          denied: []
          deniedRegex: ''
        forbiddenLabels:
          denied: []
          deniedRegex: ''
EOF
}

