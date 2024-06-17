resource "kubectl_manifest" "ValidatingWebhookConfiguration_capsule-validating-webhook-configuration" {
  yaml_body  = <<-EOF
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingWebhookConfiguration
    metadata:
      name: capsule-validating-webhook-configuration
      labels: ${jsonencode(local.common_labels)}
      annotations:
        cert-manager.io/inject-ca-from: ${var.namespace}/capsule-webhook-cert
      ownerReferences: ${jsonencode(var.install_owner)}
    webhooks:
    - admissionReviewVersions:
      - v1
      - v1beta1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /cordoning
      failurePolicy: Fail
      matchPolicy: Equivalent
      name: cordoning.tenant.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
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
      timeoutSeconds: 30
    - admissionReviewVersions:
      - v1
      - v1beta1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /ingresses
      failurePolicy: Fail
      matchPolicy: Equivalent
      name: ingress.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
      rules:
      - apiGroups:
        - networking.k8s.io
        - extensions
        apiVersions:
        - v1
        - v1beta1
        operations:
        - CREATE
        - UPDATE
        resources:
        - ingresses
        scope: Namespaced
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
          path: /namespaces
      failurePolicy: Fail
      matchPolicy: Equivalent
      name: namespaces.projectcapsule.dev
      namespaceSelector: {}
      objectSelector: {}
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        - UPDATE
        - DELETE
        resources:
        - namespaces
        scope: '*'
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
          path: /networkpolicies
      failurePolicy: Fail
      matchPolicy: Equivalent
      name: networkpolicies.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
      rules:
      - apiGroups:
        - networking.k8s.io
        apiVersions:
        - v1
        operations:
        - UPDATE
        - DELETE
        resources:
        - networkpolicies
        scope: Namespaced
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
          path: /nodes
      failurePolicy: Fail
      name: nodes.projectcapsule.dev
      matchPolicy: Exact
      namespaceSelector: {}
      objectSelector: {}
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - UPDATE
        resources:
        - nodes
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
          path: /pods
      failurePolicy: Fail
      matchPolicy: Exact
      name: pods.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        - UPDATE
        resources:
        - pods
        scope: Namespaced
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
          path: /persistentvolumeclaims
      failurePolicy: Fail
      name: pvc.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        resources:
        - persistentvolumeclaims
        scope: Namespaced
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
          path: /services
      failurePolicy: Fail
      matchPolicy: Exact
      name: services.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector: {}
      rules:
      - apiGroups:
        - ''
        apiVersions:
        - v1
        operations:
        - CREATE
        - UPDATE
        resources:
        - services
        scope: Namespaced
      sideEffects: None
      timeoutSeconds: 30
    - admissionReviewVersions:
      - v1
      clientConfig:
        service:
          name: ${kubectl_manifest.svc.name}
          namespace: ${var.namespace}
          port: 443
          path: /tenantresource-objects
      failurePolicy: Fail
      name: resource-objects.tenant.projectcapsule.dev
      namespaceSelector:
        matchExpressions:
        - key: capsule.clastix.io/tenant
          operator: Exists
      objectSelector:
        matchExpressions:
        - key: capsule.clastix.io/resources
          operator: Exists
      rules:
      - apiGroups:
        - '*'
        apiVersions:
        - '*'
        operations:
        - UPDATE
        - DELETE
        resources:
        - '*'
        scope: Namespaced
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
          path: /tenants
      failurePolicy: Fail
      matchPolicy: Exact
      name: tenants.projectcapsule.dev
      namespaceSelector: {}
      objectSelector: {}
      rules:
      - apiGroups:
        - capsule.clastix.io
        apiVersions:
        - v1beta2
        operations:
        - CREATE
        - UPDATE
        - DELETE
        resources:
        - tenants
        scope: '*'
      sideEffects: None
      timeoutSeconds: 30
EOF
}

