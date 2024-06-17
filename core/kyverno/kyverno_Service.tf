resource "kubectl_manifest" "Service_kyverno-background-controller-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-background-controller-metrics
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 8000
        targetPort: 8000
        protocol: TCP
        name: metrics-port
      selector:
        app.kubernetes.io/component: background-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "Service_kyverno-cleanup-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-cleanup-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 443
        targetPort: https
        protocol: TCP
        name: https
      selector:
        app.kubernetes.io/component: cleanup-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "Service_kyverno-svc" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-svc
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 443
        targetPort: https
        protocol: TCP
        name: https
      selector:
        app.kubernetes.io/component: admission-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "Service_kyverno-cleanup-controller-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-cleanup-controller-metrics
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 8000
        targetPort: 8000
        protocol: TCP
        name: metrics-port
      selector:
        app.kubernetes.io/component: cleanup-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "Service_kyverno-reports-controller-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-reports-controller-metrics
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 8000
        targetPort: 8000
        protocol: TCP
        name: metrics-port
      selector:
        app.kubernetes.io/component: reports-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

resource "kubectl_manifest" "Service_kyverno-svc-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: kyverno-svc-metrics
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      ports:
      - port: 8000
        targetPort: 8000
        protocol: TCP
        name: metrics-port
      selector:
        app.kubernetes.io/component: admission-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      type: ClusterIP
EOF
}

