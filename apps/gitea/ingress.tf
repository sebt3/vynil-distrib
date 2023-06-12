
locals {
    dns-names = ["${var.sub-domain}.${var.domain-name}"]
    middlewares = [{"name" = "${var.instance}-https"}]
    services = [{
      "kind" = "Service"
      "name" = "gitea-http"
      "namespace" = var.namespace
      "port" = 3000
    }]
    routes = [ for v in local.dns-names : {
      "kind" = "Rule"
      "match" = "Host(`${v}`)"
      "middlewares" = local.middlewares
      "services" = local.services
    }]
}

resource "kubernetes_manifest" "gitea_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata   = {
      name      = "${var.instance}"
      namespace = var.namespace
      labels    = local.common-labels
    }
    spec = {
        secretName = "${var.instance}-cert"
        dnsNames   = local.dns-names
        issuerRef  = {
          name  = var.issuer
          kind  = "ClusterIssuer"
          group = "cert-manager.io"
        }
    }
  }
}

resource "kubernetes_manifest" "gitea_https_redirect" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata   = {
      name      = "${var.instance}-https"
      namespace = var.namespace
      labels    = local.common-labels
    }
    spec = {
      redirectScheme = {
        scheme = "https"
        permanent = true
      }
    }
  }
}

resource "kubernetes_manifest" "gitea_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "${var.instance}"
      namespace = var.namespace
      labels    = local.common-labels
      annotations = {
        "kubernetes.io/ingress.class" = var.ingress-class
      }
    }
    spec = {
      entryPoints = ["web","websecure"]
      routes = local.routes
      tls = {
        secretName = "${var.instance}-cert"
      }
    }
  }
}
