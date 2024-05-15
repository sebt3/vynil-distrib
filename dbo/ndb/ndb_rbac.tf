resource "kubectl_manifest" "webhook_sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.instance}-${var.component}-webhook"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
EOF
}

resource "kubectl_manifest" "operator_sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.instance}-${var.component}-operator"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
EOF
}

resource "kubectl_manifest" "operator_cr" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}-operator"
      labels: ${jsonencode(local.common-labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - list
      - watch
      - delete
    - apiGroups:
      - ''
      resources:
      - serviceaccounts
      verbs:
      - list
      - watch
      - delete
      - create
    - apiGroups:
      - ''
      resources:
      - persistentvolumeclaims
      verbs:
      - list
      - watch
      - delete
    - apiGroups:
      - ''
      resources:
      - services
      verbs:
      - list
      - watch
      - create
      - patch
      - delete
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - create
      - patch
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
      - create
      - delete
      - list
      - watch
    - apiGroups:
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
      - patch
    - apiGroups:
      - apps
      resources:
      - statefulsets
      verbs:
      - create
      - patch
      - list
      - watch
      - delete
    - apiGroups:
      - policy
      resources:
      - poddisruptionbudgets
      verbs:
      - list
      - watch
      - create
    - apiGroups:
      - mysql.oracle.com
      resources:
      - ndbclusters
      - ndbclusters/status
      verbs:
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "webhook_cr" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}-webhook"
      labels: ${jsonencode(local.common-labels)}
    rules:
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - validatingwebhookconfigurations
      - mutatingwebhookconfigurations
      verbs:
      - list
      - patch
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
EOF
}

resource "kubectl_manifest" "webhook_crb" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}-webhook"
      labels: ${jsonencode(local.common-labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.webhook_cr.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.webhook_sa.name}
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "operator-crb" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}-operator"
      labels: ${jsonencode(local.common-labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.operator_cr.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.operator_sa.name}
      namespace: ${var.namespace}
EOF
}
