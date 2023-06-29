resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
  EOF
}

resource "kubectl_manifest" "role" {
  count = var.admin.namespace?1:0
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    rules:
    - apiGroups: ['*']
      resources: ['*']
      verbs: ['*']
  EOF
}
resource "kubectl_manifest" "rb" {
  count = var.admin.namespace?1:0
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      namespace: "${var.namespace}"
      name: "${var.component}-${var.instance}"
    subjects:
    - kind: ServiceAccount
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
  EOF
}
resource "kubectl_manifest" "clusterrole" {
  count = var.admin.cluster?1:0
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: "${var.component}-${var.namespace}-${var.instance}"
      labels: ${jsonencode(local.common-labels)}
    rules:
    - apiGroups: ['*']
      resources: ['*']
      verbs: ['*']
  EOF
}
resource "kubectl_manifest" "crb" {
  count = var.admin.cluster?1:0
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: "${var.component}-${var.namespace}-${var.instance}"
      labels: ${jsonencode(local.common-labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: "${var.component}-${var.namespace}-${var.instance}"
    subjects:
    - kind: ServiceAccount
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
  EOF
}
