locals {
    labels = {
      "vynil.solidite.fr/owner-namespace" = var.namespace
      "vynil.solidite.fr/owner-category" = "core"
      "vynil.solidite.fr/owner-component" = "cert-manager-self-sign"
      "app.kubernetes.io/managed-by" = "vynil"
    }
}
resource "kubernetes_manifest" "selfsigned-issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"   = "letsencrypt-prod"
      "labels" = local.labels
    }
    "spec" = {
      "acme" = {
        # The ACME server URL
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        # Email address used for ACME registration
        "email" = var.mail
        # Name of a secret used to store the ACME account private key
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-secret"
        }
        # Enable the HTTP-01 challenge provider
        "solvers" = [{
          "http01" = {
              "ingress" = {
                "class" = var.ingress-class
              }
          }
        }]
      }
    }
  }
}
