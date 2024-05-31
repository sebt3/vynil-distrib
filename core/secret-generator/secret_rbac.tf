resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ${var.instance}-${var.component}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
EOF
}
resource "kubectl_manifest" "role" {
  yaml_body  = <<-EOF
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ${var.instance}-${var.component}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - create
      - delete
      - get
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - delete
      - get
    - apiGroups:
      - monitoring.coreos.com
      resources:
      - servicemonitors
      verbs:
      - get
      - create
EOF
}

resource "kubectl_manifest" "cr" {
  yaml_body  = <<-EOF
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ${var.namespace}-${var.instance}-${var.component}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
      - create
      - list
      - watch
      - update
    - apiGroups:
      - secretgenerator.mittwald.de
      resources:
      - basicauths
      - basicauths/status
      - sshkeypairs
      - sshkeypairs/status
      - stringsecrets
      - stringsecrets/status
      verbs:
      - get
      - list
      - watch
      - update
EOF
}

resource "kubectl_manifest" "rb" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ${kubectl_manifest.role.name}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa.name}
    roleRef:
      kind: Role
      name: ${kubectl_manifest.role.name}
      apiGroup: rbac.authorization.k8s.io
EOF
}

resource "kubectl_manifest" "crb" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ${kubectl_manifest.cr.name}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa.name}
      namespace: ${var.namespace}
    roleRef:
      kind: ClusterRole
      name: ${kubectl_manifest.cr.name}
      apiGroup: rbac.authorization.k8s.io
EOF
}

