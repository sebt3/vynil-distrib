resource "kubectl_manifest" "ClusterRole_kuberest" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kuberest
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kuberest.solidite.fr
      resources:
      - restendpoints
      - restendpoints/status
      - restendpoints/finalizers
      verbs:
      - get
      - list
      - watch
      - patch
      - update
    - apiGroups:
      - ''
      resources:
      - secrets
      - configmaps
      verbs:
      - '*'
    - apiGroups:
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kuberest" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: kuberest
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kuberest
    subjects:
    - kind: ServiceAccount
      name: kuberest
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
      name: kuberest
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

