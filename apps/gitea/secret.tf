
resource "kubectl_manifest" "gitea_secret" {
  yaml_body  = <<-EOF
    apiVersion: "secretgenerator.mittwald.de/v1alpha1"
    kind: "StringSecret"
    metadata:
      name: "gitea-admin-user"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      forceRegenerate: false
      data:
        username: "${var.admin.name}"
      fields:
      - fieldName: "password"
        length: "32"
  EOF
}
