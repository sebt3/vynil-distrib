resource "kubernetes_manifest" "selfsigned-issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "selfsigned-issuer"
      "labels" = {
        "app.kubernetes.io/managed-by" = "vynil"
      }
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
      "labels" = {
        "app.kubernetes.io/managed-by" = "vynil"
      }
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
      "name"      = "ca-issuer"
      "labels" = {
        "app.kubernetes.io/managed-by" = "vynil"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = "selfsigned-ca"
      }
    }
  }
}

