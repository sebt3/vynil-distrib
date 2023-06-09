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
      "name"   = "selfsigned-issuer"
      "labels" = local.labels
    }
    "spec" = {
      "selfSigned" = {}
    }
  }
}

resource "kubernetes_manifest" "selfsigned-ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "selfsigned-ca"
      "namespace" = var.namespace
      "labels"    = local.labels
    }
    "spec" = {
      "isCA" = true
      "commonName" = "self-signed"
      "secretName" = "selfsigned-ca"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size" = 256
      }
      "issuerRef" = {
        "name" = "selfsigned-issuer"
        "kind" = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }
}

resource "kubernetes_manifest" "ca-issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"   = "ca-issuer"
      "labels" = local.labels
    }
    "spec" = {
      "ca" = {
        "secretName" = "selfsigned-ca"
      }
    }
  }
}

