locals {
    dns-names = ["${var.sub-domain}.${var.domain-name}"]
    middlewares = ["${var.instance}-https"]
    service = {
      "name"  = "${var.instance}"
      "port" = {
        "number" = 80
      }
    }
    rules = [ for v in local.dns-names : {
      "host" = "${v}"
      "http" = {
        "paths" = [{
          "backend"  = {
            "service" = local.service
          }
          "path"     = "/"
          "pathType" = "Prefix"
        }]
      }
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

resource "kubectl_manifest" "prj_https_redirect" {
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

resource "kubectl_manifest" "prj_ingress" {
  force_conflicts = true
  yaml_body  = <<-EOF
    apiVersion: "networking.k8s.io/v1"
    kind: "Ingress"
    metadata:
      name: "${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
      annotations:
        "traefik.ingress.kubernetes.io/router.middlewares": "${join(",", [for m in local.middlewares : format("%s-%s@kubernetescrd", var.namespace, m)])}"
    spec:
      ingressClassName: "${var.ingress-class}"
      rules: ${jsonencode(local.rules)}
      tls:
      - hosts: ${jsonencode(local.dns-names)}
        secretName: "${var.instance}-cert"
  EOF
}
