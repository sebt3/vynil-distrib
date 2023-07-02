resource "kubectl_manifest" "pvc" {
  yaml_body  = <<-EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${var.instance}
  namespace: "${var.namespace}"
  annotations:
    k8up.io/backup: "true"
  labels: ${jsonencode(local.common-labels)}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: "${var.storage.size}"
  EOF
}
