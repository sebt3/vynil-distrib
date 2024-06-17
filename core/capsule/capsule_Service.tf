resource "kubectl_manifest" "svc_metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: capsule-controller-manager-metrics-service
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 8080
        name: metrics
        protocol: TCP
        targetPort: 8080
      selector: ${jsonencode(local.selector)}
      sessionAffinity: None
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "svc" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: capsule-webhook-service
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 443
        name: https
        protocol: TCP
        targetPort: 9443
      selector: ${jsonencode(local.selector)}
      sessionAffinity: None
      type: ClusterIP
EOF
}

