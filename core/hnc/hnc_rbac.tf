resource "kubectl_manifest" "RoleBinding_hnc-leader-election-rolebinding" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: hnc-leader-election-rolebinding
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: hnc-leader-election-role
    subjects:
    - kind: ServiceAccount
      name: hnc
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRole_hnc-manager-role" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: hnc-manager-role
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - resourcequotas
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - '*'
      resources:
      - '*'
      verbs:
      - '*'
    - apiGroups:
      - ''
      resources:
      - namespaces
      verbs:
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - hnc.x-k8s.io
      resources:
      - hierarchicalresourcequotas
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - hnc.x-k8s.io
      resources:
      - hierarchicalresourcequotas/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - hnc.x-k8s.io
      resources:
      - hierarchies
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - hnc.x-k8s.io
      resources:
      - hierarchies/status
      verbs:
      - get
      - patch
      - update
EOF
}

resource "kubectl_manifest" "Role_hnc-leader-election-role" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: hnc-leader-election-role
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
    - apiGroups:
      - ''
      resources:
      - configmaps/status
      verbs:
      - get
      - update
      - patch
    - apiGroups:
      - ''
      resources:
      - events
      verbs:
      - create
EOF
}

resource "kubectl_manifest" "ClusterRole_hnc-admin-role" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: hnc-admin-role
    rules:
    - apiGroups:
      - hnc.x-k8s.io
      resources:
      - '*'
      verbs:
      - '*'
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_hnc-manager-rolebinding" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: hnc-manager-rolebinding
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: hnc-manager-role
    subjects:
    - kind: ServiceAccount
      name: hnc
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kuberest" {
  yaml_body  = <<-EOF
    apiVersion: v1
    automountServiceAccountToken: true
    kind: ServiceAccount
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: hnc
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

