
resource "kubectl_manifest" "sa_manager" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.instance}-${var.component}-manager"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.manager_all_labels)}
EOF
}

resource "kubectl_manifest" "cr_manager_svc" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels: ${jsonencode(local.manager_all_labels)}
      name: rabbitmq-cluster-service-binding-role
    rules:
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters
      verbs:
      - get
      - list
      - watch
EOF
}


resource "kubectl_manifest" "cr_manager" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels: ${jsonencode(local.manager_all_labels)}
      name: rabbitmq-cluster-operator-role
    rules:
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - endpoints
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - events
      verbs:
      - create
      - get
      - patch
    - apiGroups:
      - ''
      resources:
      - persistentvolumeclaims
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - pods/exec
      verbs:
      - create
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - serviceaccounts
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - services
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - apps
      resources:
      - statefulsets
      verbs:
      - create
      - delete
      - get
      - list
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters/status
      verbs:
      - get
      - update
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - rolebindings
      verbs:
      - create
      - get
      - list
      - update
      - watch
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - roles
      verbs:
      - create
      - get
      - list
      - update
      - watch
EOF
}

resource "kubectl_manifest" "r_manager_leader" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      labels: ${jsonencode(local.manager_all_labels)}
      name: "${var.instance}-${var.component}-manager-leadelec"
      namespace: ${var.namespace}
    rules:
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
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
      - events
      verbs:
      - create
EOF
}

resource "kubectl_manifest" "crb_manager" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      labels: ${jsonencode(local.manager_all_labels)}
      name: ${kubectl_manifest.cr_manager.name}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.cr_manager.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa_manager.name}
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "rb_manager" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      labels: ${jsonencode(local.manager_all_labels)}
      name: ${kubectl_manifest.r_manager_leader.name}
      namespace: ${var.namespace}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: ${kubectl_manifest.r_manager_leader.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa_manager.name}
      namespace: ${var.namespace}
EOF
}

