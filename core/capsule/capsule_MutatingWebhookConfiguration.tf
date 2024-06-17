resource "kubectl_manifest" "mwc" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: MutatingWebhookConfiguration
    metadata:
      name: capsule-mutating-webhook-configuration
      labels: ${jsonencode(local.common_labels)}
      annotations:
        cert-manager.io/inject-ca-from: ${var.namespace}/capsule-webhook-cert
    webhooks:
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /defaults
      failurePolicy: Fail
      name: pod.defaults.projectcapsule.dev
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        resources:
        - pods
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      sideEffects: None
      timeoutSeconds: 30
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /defaults
      failurePolicy: Fail
      name: storage.defaults.projectcapsule.dev
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        resources:
        - persistentvolumeclaims
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      sideEffects: None
      timeoutSeconds: 30
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /defaults
      failurePolicy: Fail
      name: ingress.defaults.projectcapsule.dev
      rules:
      - apiGroups:
        - networking.k8s.io
        apiVersions:
        - v1beta1
        - v1
        operations:
        - CREATE
        - UPDATE
        resources:
        - ingresses
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      sideEffects: None
      timeoutSeconds: 30
    - admissionReviewVersions:
      - v1
      - v1beta1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /namespace-owner-reference
      failurePolicy: Fail
      matchPolicy: Equivalent
      name: owner.namespace.projectcapsule.dev
      namespaceSelector: {}
      objectSelector: {}
      reinvocationPolicy: Never
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
        scope: '*'
      sideEffects: NoneOnDryRun
      timeoutSeconds: 30
EOF
}

