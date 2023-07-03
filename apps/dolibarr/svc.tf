resource "kubectl_manifest" "svc" {
  yaml_body  = <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: ${var.instance}
  namespace: "${var.namespace}"
  labels: ${jsonencode(local.deploy-labels)}
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 3000
  selector: ${jsonencode(local.deploy-labels)}
  type: ClusterIP
  EOF
}
