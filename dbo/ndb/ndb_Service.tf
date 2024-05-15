resource "kubectl_manifest" "webhook_service" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: "${var.instance}-${var.component}-webhook"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
    spec:
      ports:
      - port: 9443
      selector:
        app.kubernetes.io/name: ${var.component}
        app.kubernetes.io/instance: ${var.instance}
        app.kubernetes.io/component: webhook
EOF
}

resource "kubectl_manifest" "operator_service" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: "ndb-operator-svc"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
    spec:
      selector:
        app.kubernetes.io/name: ${var.component}
        app.kubernetes.io/instance: ${var.instance}
        app.kubernetes.io/component: operator
      clusterIP: None
EOF
}

