resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: capsule
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}


resource "kubectl_manifest" "crb" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: capsule-manager-rolebinding
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa.name}
      namespace: ${var.namespace}
EOF
}
