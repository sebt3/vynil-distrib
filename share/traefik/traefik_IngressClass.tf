resource "kubectl_manifest" "IngressClass_traefik" {
  yaml_body  = <<-EOF
    apiVersion: networking.k8s.io/v1
    kind: IngressClass
    metadata:
      annotations:
        ingressclass.kubernetes.io/is-default-class: '${var.is-default}'
      labels: ${jsonencode(local.common_labels)}
      name: ${var.ingressClass}
      namespace: ${var.namespace}
    spec:
      controller: traefik.io/ingress-controller
EOF
}

