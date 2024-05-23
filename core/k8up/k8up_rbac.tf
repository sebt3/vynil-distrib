resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.instance}-${var.component}"
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
EOF
}


resource "kubectl_manifest" "ClusterRole_k8up-executor" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: k8up-executor
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - get
      - list
    - apiGroups:
      - ''
      resources:
      - pods/exec
      verbs:
      - create
    - apiGroups:
      - k8up.io
      resources:
      - snapshots
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "k8up-manager" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: k8up-manager
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - apps
      resources:
      - deployments
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - batch
      resources:
      - jobs
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
      - get
      - list
      - update
    - apiGroups:
      - ''
      resources:
      - events
      verbs:
      - create
      - patch
    - apiGroups:
      - ''
      resources:
      - persistentvolumeclaims
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - persistentvolumes
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - serviceaccounts
      verbs:
      - create
      - delete
      - get
      - list
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - archives
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - archives/finalizers
      - archives/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - backups
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - backups/finalizers
      - backups/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - checks
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - checks/finalizers
      - checks/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - effectiveschedules
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - effectiveschedules/finalizers
      verbs:
      - update
    - apiGroups:
      - k8up.io
      resources:
      - podconfigs
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - prebackuppods
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - prebackuppods/finalizers
      - prebackuppods/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - prunes
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - prunes/finalizers
      - prunes/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - restores
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - restores/finalizers
      - restores/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - schedules
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - schedules/finalizers
      - schedules/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - k8up.io
      resources:
      - snapshots
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - k8up.io
      resources:
      - snapshots/finalizers
      - snapshots/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rbac.authorization.k8s.io
      resourceNames:
      - k8up-executor
      resources:
      - clusterroles
      verbs:
      - bind
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - rolebindings
      verbs:
      - create
      - delete
      - get
      - list
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_k8up-edit" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: k8up-edit
    rules:
    - apiGroups:
      - k8up.io
      resources:
      - '*'
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_k8up-view" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: k8up-view
    rules:
    - apiGroups:
      - k8up.io
      resources:
      - '*'
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_k8up" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}"
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.k8up-manager.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa.name}
      namespace: ${var.namespace}
EOF
}

