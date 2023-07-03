locals {
    dns-names = ["${var.sub-domain}.${var.domain-name}"]
    middlewares = []
    services = [{
      "kind" = "Service"
      "name" = "kubernetes"
      "namespace"  = "default"
      "port"       = 443
    }]
    routes = [ for v in local.dns-names : {
      "kind"         = "Rule"
      "match"        = "Host(`${v}`)"
      "middlewares"  = local.middlewares
      "services"     = local.services
    }]
}

resource "kubectl_manifest" "prj_certificate" {
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

resource "kubectl_manifest" "prj_ingress" {
  force_conflicts = true
  yaml_body  = <<-EOF
    apiVersion: "traefik.containo.us/v1alpha1"
    kind: "IngressRoute"
    metadata:
      name: "${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      entryPoints: ["websecure"]
      routes: ${jsonencode(local.routes)}
      tls:
        secretName: "${var.instance}-cert"
  EOF
}
