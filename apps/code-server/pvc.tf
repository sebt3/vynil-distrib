resource "kubectl_manifest" "pvc" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      accessModes:
      - "${var.storage.accessMode}"
      resources:
        requests:
          storage: "${var.storage.size}"
      volumeMode: "${var.storage.type}"
  EOF
}
