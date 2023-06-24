
resource "kubectl_manifest" "authentik_secret" {
  ignore_fields = ["metadata.annotations"]
  yaml_body  = <<-EOF
    apiVersion: "secretgenerator.mittwald.de/v1alpha1"
    kind: "StringSecret"
    metadata:
      name: "${var.component}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      forceRegenerate: false
      fields:
      - fieldName: "AUTHENTIK_SECRET_KEY"
        length: "128"
      - fieldName: "AUTHENTIK_BOOTSTRAP_PASSWORD"
        length: "32"
      - fieldName: "AUTHENTIK_BOOTSTRAP_TOKEN"
        length: "64"
      - fieldName: "AUTHENTIK_REDIS__PASSWORD"
        length: "32"
  EOF
}
