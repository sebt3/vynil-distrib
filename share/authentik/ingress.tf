
locals {
    dns-names = ["${var.sub-domain}.${var.domain-name}"]
    middlewares = [{"name" = "${var.instance}-https"}]
    services = [{
      "kind"       = "Service"
      "name"       = "${var.instance}"
      "namespace"  = var.namespace
      "port"       = 80
    }]
    routes = [ for v in local.dns-names : {
      "kind"         = "Rule"
      "match"        = "Host(`${v}`)"
      "middlewares"  = local.middlewares
      "services"     = local.services
    }]
}

resource "kubectl_manifest" "authentik_certificate" {
  yaml_body  = <<-EOF
    apiVersion: "cert-manager.io/v1"
    kind: "Certificate"
    metadata:
      name: "${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
        secretName: "${var.instance}-cert"
        dnsNames: ${jsonencode(local.dns-names)}
        issuerRef:
          name: "${var.issuer}"
          kind: "ClusterIssuer"
          group: "cert-manager.io"
  EOF
}

resource "kubectl_manifest" "authentik_https_redirect" {
  yaml_body  = <<-EOF
    apiVersion: "traefik.containo.us/v1alpha1"
    kind: "Middleware"
    metadata:
      name: "${var.instance}-https"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      redirectScheme:
        scheme: "https"
        permanent: true
  EOF
}

resource "kubectl_manifest" "authentik_ingress" {
  field_manager {
    force_conflicts = true
  }
  yaml_body  = <<-EOF
    apiVersion: "traefik.containo.us/v1alpha1"
    kind: "IngressRoute"
    metadata:
      name: "${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
      # Failing
      # annotations:
      #   "kubernetes.io/ingress.class": "${var.ingress-class}"
    spec:
      entryPoints: ["web","websecure"]
      routes: ${jsonencode(local.routes)}
      tls:
        secretName: "${var.instance}-cert"
  EOF
}
