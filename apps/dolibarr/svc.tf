resource "kubectl_manifest" "svc" {
  yaml_body  = <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: ${var.instance}
  namespace: "${var.namespace}"
  labels: ${jsonencode(local.common-labels)}
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 3000
  selector: ${jsonencode(local.common-labels)}
  type: ClusterIP
  EOF
}
