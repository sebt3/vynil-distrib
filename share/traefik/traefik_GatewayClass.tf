resource "kubectl_manifest" "GatewayClass_traefik" {
  count = var.conditions.have_gateway?1:0
  yaml_body  = <<-EOF
    apiVersion: gateway.networking.k8s.io/v1
    kind: GatewayClass
    metadata:
      name: ${var.ingressClass}
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
    spec:
      controllerName: traefik.io/gateway-controller
EOF
}

