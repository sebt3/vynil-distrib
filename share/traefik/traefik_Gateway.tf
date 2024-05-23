resource "kubectl_manifest" "Gateway_traefik-gateway" {
  count = var.conditions.have_gateway?1:0
  yaml_body  = <<-EOF
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: traefik-gateway
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
    spec:
      gatewayClassName: ${var.ingressClass}
      listeners:
      - name: web
        port: 8000
        protocol: HTTP
EOF
}

