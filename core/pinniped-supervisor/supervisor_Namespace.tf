resource "kubectl_manifest" "Namespace_pinniped-supervisor" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: pinniped-supervisor
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

