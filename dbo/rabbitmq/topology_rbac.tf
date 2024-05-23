resource "kubectl_manifest" "sa_topology" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.instance}-${var.component}-topology"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.topology_all_labels)}
EOF
}

resource "kubectl_manifest" "r_topology" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      labels: ${jsonencode(local.topology_all_labels)}
      name: "${var.instance}-${var.component}-topology"
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
EOF
}

resource "kubectl_manifest" "cr_topology" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: messaging-topology-manager-role
      labels: ${jsonencode(local.topology_all_labels)}
    rules:
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
      - secrets
      verbs:
      - create
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - services
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - bindings
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - bindings/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - bindings/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - exchanges
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - exchanges/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - exchanges/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - federations
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - federations/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - federations/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - operatorpolicies
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - operatorpolicies/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - operatorpolicies/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - permissions
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - permissions/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - permissions/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - policies
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - policies/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - policies/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - queues
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - queues/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - queues/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - rabbitmqclusters/status
      verbs:
      - get
    - apiGroups:
      - rabbitmq.com
      resources:
      - schemareplications
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - schemareplications/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - schemareplications/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - shovels
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - shovels/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - shovels/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - superstreams
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - superstreams/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - superstreams/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - topicpermissions
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - topicpermissions/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - topicpermissions/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - users
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - users/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - users/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - vhosts
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - rabbitmq.com
      resources:
      - vhosts/finalizers
      verbs:
      - update
    - apiGroups:
      - rabbitmq.com
      resources:
      - vhosts/status
      verbs:
      - get
      - patch
      - update
EOF
}

resource "kubectl_manifest" "crb_topology" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: messaging-topology-manager-rolebinding
      labels: ${jsonencode(local.topology_all_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.cr_topology.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa_topology.name}
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "rb_topology" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ${kubectl_manifest.r_topology.name}
      namespace: ${var.namespace}
      labels: ${jsonencode(local.topology_all_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: ${kubectl_manifest.r_topology.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa_topology.name}
      namespace: ${var.namespace}
EOF
}
